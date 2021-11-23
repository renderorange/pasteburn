use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/../../../lib", "$FindBin::RealBin/../../lib";
use Pasteburn::Test;

my $class = 'Pasteburn::DB';
use_ok( $class );

HAPPY_PATH: {
    note( 'happy path' );

    Pasteburn::Test::override(
        package => 'DBI',
        name    => 'connect',
        subref  => sub {
            return bless {}, 'DBI::db',
        },
    );

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

TODO: {
    # this is a little strange to TODO block around done_testing.
    # the failure being worked around here is the following, which fails during the no_warnings test:
    # (in cleanup) dbih_getcom handle DBI::db=HASH(0x55b9b84866f0) is not a DBI handle (has no magic)
    local $TODO = 'more mocking is required for the handle returned from DBI::connect';
    done_testing;
};
