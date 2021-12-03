use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/../../../lib", "$FindBin::RealBin/../../lib";
use Pasteburn::Test skip_db => 1;

my $class = 'Pasteburn::Crypt::Storage';
use_ok( $class );

HAPPY_PATH: {
    note( 'happy path' );

    my $string = 'foo';

    my $crypt = $class->new( passphrase => $string );
    my $encoded = $crypt->encode( secret => 'fooz' );

    unlike( $encoded, qr/$string/, 'returned string is encoded' );
}

EXCEPTIONS: {
    note( 'exceptions' );

    my $crypt = $class->new( passphrase => 'foo' );

    dies_ok( sub { $crypt->encode() }, "dies if secret is not passed" );
    like $@, qr/secret argument is required/, "message matches expected string";
}

done_testing();
