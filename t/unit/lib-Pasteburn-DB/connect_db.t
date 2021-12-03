use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/../../../lib", "$FindBin::RealBin/../../lib";
use Pasteburn::Test;

my $class = 'Pasteburn::DB';
use_ok( $class );

HAPPY_PATH: {
    note( 'happy path' );

    my $dbh = Pasteburn::DB::connect_db();

    isa_ok( $dbh, 'DBI::db' );
}

EXCEPTIONS: {
    note( 'exceptions' );

    Pasteburn::Test::override(
        package => 'DBI',
        name    => 'connect',
        subref  => sub { die "fake your own death\n" },
    );

    dies_ok( sub { Pasteburn::DB::connect_db() }, 'dies if DBI->connect fails' );
}

done_testing;
