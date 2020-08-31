use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/../../../lib", "$FindBin::RealBin/../../lib";
use Pasteburn::Test;

my $class = 'Pasteburn::Crypt::Hash';
use_ok( $class );

HAPPY_PATH: {
    note( 'happy path' );

    my $string = 'foo';

    my $crypt = $class->new();
    my $hash = $crypt->generate( string => $string );

    ok( $crypt->validate( hash => $hash, string => $string ), 'string validates as true' );
    ok( !$crypt->validate( hash => $hash, string => 'fooz' ), 'string validates as false' );
}

EXCEPTIONS: {
    note( 'exceptions' );

    my $crypt = $class->new();

    dies_ok( sub { $crypt->validate( hash => 'fake' ) },
             "dies if string is not passed" );
    like $@, qr/string is required/, "message matches expected string";
    dies_ok( sub { $crypt->validate( string => 'fake' ) },
             "dies if hash is not passed" );
    like $@, qr/hash is required/, "message matches expected string";
}

done_testing();
