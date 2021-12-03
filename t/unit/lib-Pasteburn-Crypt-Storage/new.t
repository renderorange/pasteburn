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

EXCEPTIONS: {
    note( 'exceptions' );

    dies_ok( sub { $class->new() },
             "dies if passphrase is not passed" );
    like $@, qr/passphrase argument is required/, "message matches expected string";
}

done_testing();
