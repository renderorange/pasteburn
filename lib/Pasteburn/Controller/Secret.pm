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
        route   => request->path,
        message => undef,
    };

    # TODO: check session to make sure they created that id

    return template secret => $template_params;
};

1;
