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

my $pasteburnrc = Pasteburn::Test::write_config( config => $config_expected );

Pasteburn::Test::override(
    package => 'Cwd',
    name    => 'realpath',
    subref  => sub { return $pasteburnrc },
);

HAPPY_PATH: {
    note( 'happy path' );

    my $config = Pasteburn::Config::_load_config();

    cmp_deeply( $config, $config_expected, 'returned config matches expected' );
}

EXCEPTIONS: {
    note( 'exceptions' );

    unlink $pasteburnrc;

    dies_ok { Pasteburn::Config::_load_config() } 'dies if .pasteburnrc is not present';
}

done_testing;
