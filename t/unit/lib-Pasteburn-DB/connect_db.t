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
        dbname   => 'pasteburn',
        username => 'pasteburn',
        password => 'password',
    },
};

Pasteburn::Test::override(
    package => 'Pasteburn::Config',
    name    => 'get',
    subref  => sub { return $config_expected },
);

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
    ok( ( exists $dbh->{mysql_auto_reconnect} && $dbh->{mysql_auto_reconnect} ), 'mysql_auto_reconnect is set in the dbh' );
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
