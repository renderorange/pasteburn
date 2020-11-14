use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/../../../lib", "$FindBin::RealBin/../../lib";
use Pasteburn::Test;

my $class = 'Pasteburn::DB';
use_ok( $class );

my $config_expected = {
    database => {
        type     => 'mysql',
        hostname => 'localhost',
        port     => 3306,
        dbname   => 'trackability',
        username => 'trackability',
        password => 'password',
    },
};

HAPPY_PATH: {
    note( 'happy path' );

    Pasteburn::Test::override(
        package => 'Pasteburn::Config',
        name    => 'get',
        subref  => sub { return $config_expected },
    );

    my ( $dsn, $username, $password ) = Pasteburn::DB::load();

    # dbi:mysql:database=pasteburn;host=localhost;port=3306
    my $expected_dsn = "dbi:"
                           . $config_expected->{database}{type}
                           . ":database="
                           . $config_expected->{database}{dbname}
                           . ";host="
                           . $config_expected->{database}{hostname}
                           . ";port="
                           . $config_expected->{database}{port};
    is( $dsn, $expected_dsn, 'dsn is returned containing the expected parts and format' );

    ok( $username, 'username is returned' );
    ok( $password, 'password is returned' );
}

done_testing;
