use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/../../../lib", "$FindBin::RealBin/../../lib";
use Pasteburn::Test skip_db => 1;

my $class = 'Pasteburn::Config';
use_ok( $class );

my $config_expected = {
    secret => {
        age => 1,
        scrub => 1,
    },
    passphrase => {
        allow_blank => 0,
    },
    cookie => {
        secret_key => 'testing',
    },
    footer => {
        links => 1,
    },
};

my $pasteburnrc = Pasteburn::Test::write_config( config => $config_expected );

Pasteburn::Test::override(
    package => 'Pasteburn::Config',
    name    => '_get_conf_path',
    subref  => sub { return $pasteburnrc },
);

HAPPY_PATH: {
    note( 'happy path' );

    my $config = Pasteburn::Config::_load();

    cmp_deeply( $config, $config_expected, 'returned config matches expected' );
}

EXCEPTIONS: {
    note( 'exceptions' );

    unlink $pasteburnrc;

    dies_ok { Pasteburn::Config::_load() } 'dies if config.ini is not present';
}

done_testing;
