use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/../../../lib", "$FindBin::RealBin/../../lib";
use Pasteburn::Test skip_db => 1;

use Crypt::Random ();

my $class = 'Pasteburn::Crypt::Hash';
use_ok( $class );

HAPPY_PATH: {
    note( 'happy path' );

    my $crypt = $class->new();
    my $hash = $crypt->generate( string => 'foo' );

    ok( $hash, 'return is truthy' );

    subtest 'returned string contains expected parts' => sub {
        plan tests => 4;

        my @parts = split( '!', $hash );

        ok( !$parts[0], 'NUL is appended' );
        is( $parts[1], 'bcrypt', 'method is bcrypt' );
        is( $parts[2], $crypt->{cost}, 'string contains expected cost' );
        ok( $parts[3], 'string contains salt/encrypted string' );
    };
}

GENERATE_WITH_SALT: {
    note( 'NOTE: generate with salt is implicitly tested through validate' );
}

GENERATE_WITH_EMPTY_STRING: {
    note( 'generate with empty string' );

    my $crypt = $class->new();
    my $hash = $crypt->generate( string => '' );

    ok( $hash, 'return is truthy' );

    subtest 'returned string contains expected parts' => sub {
        plan tests => 4;

        my @parts = split( '!', $hash );

        ok( !$parts[0], 'NUL is appended' );
        is( $parts[1], 'bcrypt', 'method is bcrypt' );
        is( $parts[2], $crypt->{cost}, 'string contains expected cost' );
        ok( $parts[3], 'string contains salt/encrypted string' );
    };
}

EXCEPTIONS: {
    note( 'exceptions' );

    my $crypt = $class->new();

    dies_ok( sub { $crypt->generate() }, 'dies if string is not passed' );
    like $@, qr/string is required/, 'message matches expected string';

    dies_ok( sub { $crypt->generate( string => undef ) }, 'dies if string is undef' );
    like $@, qr/string is required/, 'message matches expected string';
}

done_testing();
