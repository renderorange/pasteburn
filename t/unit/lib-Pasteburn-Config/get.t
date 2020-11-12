use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/../../../lib", "$FindBin::RealBin/../../lib";
use Pasteburn::Test;

my $class = 'Pasteburn::Config';
use_ok( $class );

my $config_expected = {
    cookie   => {
        secret_key => 'default',
    },
    database => {
        type => 'mysql',
        hostname => '127.0.0.1',
        port     => 3306,
        dbname   => 'pasteburn',
        username => 'pasteburn',
        password => 'password',
    },
};

Pasteburn::Test::override(
    package => 'Pasteburn::Config',
    name    => '_load_config',
    subref  => sub { return $config_expected },
);

Pasteburn::Test::override(
    package => 'Pasteburn::Config',
    name    => '_validate',
    subref  => sub { return 1 },
);

HAPPY_PATH: {
    note( 'happy path' );

    my $obj = $class->get();
    cmp_deeply( $obj, noclass($config_expected), 'returned config contains expected data structure' );
}

done_testing;
