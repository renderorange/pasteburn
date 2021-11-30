package Pasteburn::Controller::About;

use Dancer2 appname => 'pasteburn';

our $VERSION = '0.003';

get q{/about} => sub {
    my $template_params = {
        route  => request->path,
        footer => config->{footer},
    };

    return template about => $template_params;
};

1;
