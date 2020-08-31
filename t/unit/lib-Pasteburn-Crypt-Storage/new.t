use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/../../../lib", "$FindBin::RealBin/../../lib";
use Pasteburn::Test;

use Test::Exception;

my $class = 'Pasteburn::Crypt::Storage';
use_ok( $class );

my $crypt = $class->new( passphrase => 'test' );
isa_ok( $crypt, $class );

my @methods = qw(
    encode
    decode
);

can_ok( $class, $_ ) foreach @methods;

ok( exists $crypt->{_store_obj}, 'object contains _store_obj key' );

EXCEPTIONS: {
    note( 'exceptions' );

    dies_ok( sub { $crypt->new() },
             "dies if passphrase is not passed" );
    like $@, qr/passphrase argument is required/, "message matches expected string";
}

done_testing();
