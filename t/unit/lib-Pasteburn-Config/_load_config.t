use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/../../../lib", "$FindBin::RealBin/../../lib";
use Pasteburn::Test;

use File::Temp ();

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

my $temp_dir = File::Temp->newdir(
    DIR => $FindBin::Bin,
);

my $pasteburnrc = "$temp_dir/.pasteburnrc";

write_config( $config_expected );

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

sub write_config {
    my $config = shift;

    my $config_tiny = Config::Tiny->new;

    foreach my $key ( keys %{ $config } ) {
        $config_tiny->{ $key } = $config->{ $key };
    }

    die( "unable to write config\n" )
        unless $config_tiny->write( $pasteburnrc );

    return;
}
