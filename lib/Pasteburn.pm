package Pasteburn;

use Dancer2 appname => 'pasteburn';

use HTTP::Status ();

use Pasteburn::Controller::Root   ();
use Pasteburn::Controller::Secret ();

our $VERSION = '0.001';

any qr{.*} => sub {
    my $app = shift;

    my $template_params = {
        route   => request->path,
        message => 'That resource was not found',
    };

    response->{status} = HTTP::Status::HTTP_NOT_FOUND;
    return template error => $template_params;
};

hook on_route_exception => sub {
    my $app       = shift;
    my $exception = shift;

    my $template_params = {
        route   => request->path,
        message => 'Whoops, there was an error on our end',
    };

    log( 'error', $exception );
    response->{status} = HTTP::Status::HTTP_INTERNAL_SERVER_ERROR;
    return template error => $template_params;
};

1;
