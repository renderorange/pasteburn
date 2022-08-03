use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/../../../lib", "$FindBin::RealBin/../../lib";
use Pasteburn::Test skip_db => 1;

my $class = 'Pasteburn::Crypt::Storage';
use_ok( $class );

CONSTRUCTOR: {
    note( 'constructor' );

    my $crypt = $class->new( passphrase => 'test' );
    isa_ok( $crypt, $class );

    my @methods = qw(
        encode
        decode
    );

    can_ok( $class, $_ ) foreach @methods;

    ok( exists $crypt->{_store_obj}, 'object contains _store_obj key' );
}

CONSTRUCT_WITH_EMPTY_STRING: {
    note( 'construct with empty string' );

    lives_ok( sub { $class->new( passphrase => '' ) },
             'lives if passphrase is empty string' );
}

EXCEPTIONS: {
    note( 'exceptions' );

    dies_ok( sub { $class->new() },
             'dies if passphrase is not passed' );
    like $@, qr/passphrase argument is required/, 'message matches expected string';
    dies_ok( sub { $class->new( passphrase => undef ) },
             'dies if passphrase is undef' );
    like $@, qr/passphrase argument is required/, 'message matches expected string';
}

done_testing();
