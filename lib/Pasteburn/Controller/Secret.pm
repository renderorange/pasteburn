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

1;
