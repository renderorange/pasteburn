package Pasteburn::Controller::Secret;

use Dancer2 appname => 'pasteburn';

use HTTP::Status              ();
use Pasteburn::Model::Secrets ();

our $VERSION = '0.001';

get q{/secret} => sub {
    redirect q{/};
};

get q{/secret/:id} => sub {
    my $id = route_parameters->get('id');

    my $template_params = {
        uri     => request->uri_base,
        message => undef,
    };

    # check the db for the secret.
    my $secret_obj = Pasteburn::Model::Secrets->get( id => $id );
    unless ($secret_obj) {
        $template_params->{message} = 'That secret does not exist or has expired';
        response->{status} = HTTP::Status::HTTP_NOT_FOUND;
        return template secret => $template_params;
    }

    $template_params->{id} = $secret_obj->id;

    # check the session to see if this user created the secret.
    my $session_secrets = session->read('secrets');
    if ( exists $session_secrets->{ $secret_obj->id } ) {
        $template_params->{author} = 1;
        return template secret => $template_params;
    }

    return template secret => $template_params;
};

post q{/secret/:id} => sub {
    my $id         = route_parameters->get('id');
    my $passphrase = body_parameters->get('passphrase');

    my $template_params = {
        route   => request->path,
        message => undef,
    };

    # check the db for the secret.
    my $secret_obj = Pasteburn::Model::Secrets->get( id => $id );
    unless ($secret_obj) {
        $template_params->{message} = 'That secret does not exist or has expired';
        response->{status} = HTTP::Status::HTTP_NOT_FOUND;
        return template secret => $template_params;
    }

    $template_params->{id} = $secret_obj->id;

    unless ($passphrase) {
        $template_params->{message} = 'The passphrase parameter is required';
        response->{status} = HTTP::Status::HTTP_BAD_REQUEST;
        return template secret => $template_params;
    }

    unless ( $secret_obj->validate_passphrase( passphrase => $passphrase ) ) {
        $template_params->{message} = 'That passphrase is not correct';
        response->{status} = HTTP::Status::HTTP_UNAUTHORIZED;
        return template secret => $template_params;
    }

    my $decoded_secret = $secret_obj->decode_secret( passphrase => $passphrase );
    if ($decoded_secret) {
        $template_params->{secret} = $decoded_secret;
        return template secret => $template_params;
    }

    log( 'error', 'decoding came back empty, even though the passphrase is correct' );
    response->{status} = HTTP::Status::HTTP_INTERNAL_SERVER_ERROR;
    $template_params->{message} = "Whoops, something went wrong on our end";
    return template secret => $template_params;
};

1;
