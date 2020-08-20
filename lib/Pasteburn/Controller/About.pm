package Pasteburn::Controller::About;

use Dancer2 appname => 'pasteburn';

use HTTP::Status ();

our $VERSION = '0.001';

get q{/about} => sub {
    my $template_params = { route => request->path, };

    return template about => $template_params;
};

1;
