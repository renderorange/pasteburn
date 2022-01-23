package Pasteburn::Controller::About;

use Dancer2 appname => 'pasteburn';

our $VERSION = '0.016';

get q{/about} => sub {
    my $template_params = { footer => config->{footer} };

    return template about => $template_params;
};

1;
