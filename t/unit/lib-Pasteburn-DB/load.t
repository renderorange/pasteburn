use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/../../../lib", "$FindBin::RealBin/../../lib";
use Pasteburn::Test;

my $class = 'Pasteburn::DB';
use_ok( $class );

HAPPY_PATH: {
    note( 'happy path' );

    my ( $dsn, $username, $password ) = Pasteburn::DB::load();

    # dbi:SQLite:dbname=/path/to/pasteburn/db/pasteburn.sqlite3'
    my $expected_dsn = "dbi:SQLite:dbname=";
    like( $dsn, qr/^$expected_dsn.+\/test\.sqlite3$/, 'dsn is returned containing the expected parts and format' );

    ok( !$username, 'username is undef' );
    ok( !$password, 'password is undef' );
}

done_testing;
