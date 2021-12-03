use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/../../lib", "$FindBin::RealBin/../../../lib";
use Pasteburn::Test;
use Pasteburn::Model::Secrets;

my $secret     = 'mysecret';
my $passphrase = 'mypassphrase';
my $secret_obj = Pasteburn::Model::Secrets->new( secret => $secret, passphrase => $passphrase );
ok( $secret_obj->store, 'stored new secret' );

is( $secret_obj->decode_secret( passphrase => $passphrase ), $secret, 'matching passphrase returns decoded secret' );
ok( !$secret_obj->decode_secret( passphrase => 'incorrect' ), 'not matching passphrase returns nothing' );

done_testing;
