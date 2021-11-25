package Pasteburn::Controller::Root;

use Dancer2 appname => 'pasteburn';

use HTTP::Status              ();
use Pasteburn::Model::Secrets ();

our $VERSION = '0.002';

get q{/} => sub {
    redirect '/secret';
};

1;
