package Pasteburn::Controller::Root;

use Dancer2 appname => 'pasteburn';

our $VERSION = '0.001';

get q{/} => sub {
    my $template_params = { route => request->path, };

    return template root => $template_params;
};

1;
