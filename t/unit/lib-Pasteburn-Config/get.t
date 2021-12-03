use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/../../../lib", "$FindBin::RealBin/../../lib";
use Pasteburn::Test skip_db => 1;

my $class = 'Pasteburn::Config';
use_ok( $class );

my $config_expected = {
    cookie => {
        secret_key => 'testing',
    },
    footer => {
        links => 1,
    },
};

Pasteburn::Test::override(
    package => 'Pasteburn::Config',
    name    => '_load',
    subref  => sub { return $config_expected },
);

Pasteburn::Test::override(
    package => 'Pasteburn::Config',
    name    => '_validate',
    subref  => sub { return },
);

HAPPY_PATH: {
    note( 'happy path' );

    my $obj = $class->get();
    cmp_deeply( $obj, noclass($config_expected), 'returned config contains expected data structure' );
}

done_testing;
