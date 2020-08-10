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

    # TODO: add the secret id and created_on to the secure session storage in the browser

    redirect '/secret/' . $secret_obj->id;
};

1;
