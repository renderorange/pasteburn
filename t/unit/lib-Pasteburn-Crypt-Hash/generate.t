use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/../../../lib", "$FindBin::RealBin/../../lib";
use Pasteburn::Test skip_db => 1;

my $class = 'Pasteburn::Crypt::Hash';
use_ok( $class );

HAPPY_PATH: {
    note( 'happy path' );

    my $crypt = $class->new();
    my $hash = $crypt->generate( string => 'foo' );

    ok( $hash, 'return is truthy' );

    subtest "returned string is RFC2307 compatible" => sub {
        plan tests => 4;

        my @parts = split( ':', $hash );

        is( $parts[0], '{X-PBKDF2}HMACSHA1', 'string contains scheme (X-PBKDF2) and hash class (HMACSHA1)' );
        is( $parts[1], 'AAAD6A', 'string contains interations (encoded 1000 - AAAD6A)' );
        ok( $parts[2], 'string contains salt' );
        ok( $parts[3], 'string contains key' );
    };

}

EXCEPTIONS: {
    note( 'exceptions' );

    my $crypt = $class->new();

    dies_ok( sub { $crypt->generate() }, "dies if string is not passed" );
    like $@, qr/string is required/, "message matches expected string";
}

done_testing();
