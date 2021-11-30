package Pasteburn::Controller::Secret;

use Dancer2 appname => 'pasteburn';

use HTTP::Status              ();
use Pasteburn::Model::Secrets ();

our $VERSION = '0.003';

get q{/secret} => sub {
    my $template_params = {
        route   => request->path,
        footer  => config->{footer},
        message => undef,
    };

    return template secret => $template_params;
};

post q{/secret} => sub {
    my $secret     = body_parameters->get('secret');
    my $passphrase = body_parameters->get('passphrase');

    my $template_params = {
        route        => request->path,
        footer       => config->{footer},
        message_type => 'success',
        message      => undef,
    };

    unless ( $secret && $passphrase ) {
        $template_params->{message_type} = 'error';
        $template_params->{message}      = 'The secret and passphrase parameters are required';
        response->{status} = HTTP::Status::HTTP_BAD_REQUEST;
        return template secret => $template_params;
    }

    if ( length $secret > 10000 ) {
        $template_params->{message_type} = 'error';
        $template_params->{message}      = 'The secret parameter cannot be greater than 10000';
        response->{status} = HTTP::Status::HTTP_BAD_REQUEST;
        return template secret => $template_params;
    }

    if ( length $passphrase > 100 ) {
        $template_params->{message_type} = 'error';
        $template_params->{message}      = 'The passphrase parameter cannot be greater than 100';
        response->{status} = HTTP::Status::HTTP_BAD_REQUEST;
        return template secret => $template_params;
    }

    my $secret_obj = Pasteburn::Model::Secrets->new( secret => $secret, passphrase => $passphrase );
    $secret_obj->store;

    # add the secret id and created_at to the user's secure session cookie so we
    # can give different options in the secret view as the creator.
    my $session_secrets = session->read('secrets');
    $session_secrets->{ $secret_obj->id }{created_at} = $secret_obj->created_at;
    $session_secrets->{ $secret_obj->id }{runmode}    = 'new';
    session->write( 'secrets', $session_secrets );

    redirect '/secret/' . $secret_obj->id;
};

get q{/secret/:id} => sub {
    my $id = route_parameters->get('id');

    my $template_params = {
        footer       => config->{footer},
        message_type => 'success',
        message      => undef,
    };

    # check the db for the secret.
    my $secret_obj = Pasteburn::Model::Secrets->get( id => $id );
    unless ($secret_obj) {
        my $session_secrets = session->read('secrets');
        if ( exists $session_secrets->{$id} ) {
            delete $session_secrets->{$id};
            session->write( 'secrets', $session_secrets );
        }

        $template_params->{message_type} = 'error';
        $template_params->{message}      = 'That secret does not exist or has expired';
        response->{status} = HTTP::Status::HTTP_NOT_FOUND;
        return template secret => $template_params;
    }

    $template_params->{id} = $secret_obj->id;

    # check the session to see if this user created the secret.
    my $session_secrets = session->read('secrets');
    if ( exists $session_secrets->{ $secret_obj->id } ) {
        if ( $session_secrets->{ $secret_obj->id }{runmode} && $session_secrets->{ $secret_obj->id }{runmode} eq 'new' ) {
            $template_params->{message} = 'The secret has been created';
            delete $session_secrets->{ $secret_obj->id }{runmode};
            session->write( 'secrets', $session_secrets );
        }

        $template_params->{author} = 1;
        return template secret => $template_params;
    }

    return template secret => $template_params;
};

post q{/secret/:id} => sub {
    my $id         = route_parameters->get('id');
    my $passphrase = body_parameters->get('passphrase');
    my $run_mode   = body_parameters->get('rm');

    my $template_params = {
        route        => request->path,
        footer       => config->{footer},
        message_type => 'success',
        message      => undef,
    };

    # check the db for the secret.
    my $secret_obj = Pasteburn::Model::Secrets->get( id => $id );
    unless ($secret_obj) {
        $template_params->{message_type} = 'error';
        $template_params->{message}      = 'That secret does not exist or has expired';
        response->{status} = HTTP::Status::HTTP_NOT_FOUND;
        return template secret => $template_params;
    }

    if ( $run_mode && $run_mode eq 'del' ) {
        my $session_secrets = session->read('secrets');
        delete $session_secrets->{ $secret_obj->id };
        session->write( 'secrets', $session_secrets );

        $secret_obj->delete_secret;

        $template_params->{message} = 'The secret has been deleted';
        return template secret => $template_params;
    }

    $template_params->{id} = $secret_obj->id;

    unless ($passphrase) {
        $template_params->{message_type} = 'error';
        $template_params->{message}      = 'The passphrase parameter is required';
        response->{status} = HTTP::Status::HTTP_BAD_REQUEST;
        return template secret => $template_params;
    }

    unless ( $secret_obj->validate_passphrase( passphrase => $passphrase ) ) {
        $template_params->{message_type} = 'error';
        $template_params->{message}      = 'That passphrase is not correct';
        response->{status} = HTTP::Status::HTTP_UNAUTHORIZED;
        return template secret => $template_params;
    }

    my $decoded_secret = $secret_obj->decode_secret( passphrase => $passphrase );
    if ($decoded_secret) {

        # this will not delete from the author session unless they also view it.
        my $session_secrets = session->read('secrets');
        delete $session_secrets->{ $secret_obj->id };
        session->write( 'secrets', $session_secrets );

        $secret_obj->delete_secret;

        $template_params->{message} = 'The secret has been decrypted';
        $template_params->{secret}  = $decoded_secret;
        return template secret => $template_params;
    }

    log( 'error', 'decoding came back empty, even though the passphrase is correct' );
    response->{status} = HTTP::Status::HTTP_INTERNAL_SERVER_ERROR;
    $template_params->{message_type} = 'error';
    $template_params->{message}      = "Whoops, something went wrong on our end";
    return template secret => $template_params;
};

1;
