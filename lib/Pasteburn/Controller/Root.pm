package Pasteburn::Controller::Root;

use Dancer2 appname => 'pasteburn';

use HTTP::Status              ();
use Pasteburn::Model::Secrets ();

our $VERSION = '0.001';

get q{/} => sub {
    my $template_params = { route => request->path, };

    return template root => $template_params;
};

post q{/} => sub {
    my $secret     = body_parameters->get('secret');
    my $passphrase = body_parameters->get('passphrase');

    my $template_params = {
        route   => request->path,
        message => undef,
    };

    unless ( $secret && $passphrase ) {
        $template_params->{message} = 'The secret and passphrase parameters are required';
        response->{status} = HTTP::Status::HTTP_BAD_REQUEST;
        return template root => $template_params;
    }

    my $secret_obj = Pasteburn::Model::Secrets->new( secret => $secret, passphrase => $passphrase );
    $secret_obj->store;

    # add the secret id and created_at to the user's secure session cookie so we
    # can give different options in the secret view as the creator.
    my $session_secrets = session->read('secrets');
    $session_secrets->{ $secret_obj->id } = $secret_obj->created_at;
    session->write( 'secrets', $session_secrets );

    redirect '/secret/' . $secret_obj->id;
};

1;
