package Pasteburn::Controller::Root;

use Dancer2 appname => 'pasteburn';

our $VERSION = '0.005';

get q{/} => sub {
    redirect '/secret';
};

1;
