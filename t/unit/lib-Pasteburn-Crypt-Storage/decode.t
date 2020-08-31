use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/../../../lib", "$FindBin::RealBin/../../lib";
use Pasteburn::Test;

use Test::Exception;

my $class = 'Pasteburn::Crypt::Storage';
use_ok( $class );

HAPPY_PATH: {
    note( 'happy path' );

    my $passphrase = 'foo';
    my $secret = 'shhh';

    my $crypt = $class->new( passphrase => $passphrase );
    my $encoded = $crypt->encode( secret => $secret );
    is( $crypt->decode( secret => $encoded ), $secret, 'decoded string is expected' );

    $crypt = $class->new( passphrase => $passphrase . 'oz' );
    ok( !$crypt->decode( secret => $encoded ), 'not decoded string returns undef' );
}

EXCEPTIONS: {
    note( 'exceptions' );

    my $crypt = $class->new( passphrase => 'foo' );

    dies_ok( sub { $crypt->encode() }, "dies if secret is not passed" );
    like $@, qr/secret argument is required/, "message matches expected string";
}

done_testing();
