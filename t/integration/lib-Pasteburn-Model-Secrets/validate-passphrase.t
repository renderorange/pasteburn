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

ok( $secret_obj->validate_passphrase( passphrase => $passphrase ), 'matching passphrase validates true' );
ok( !$secret_obj->validate_passphrase( passphrase => 'incorrect' ), 'not matching passphrase validates not true' );

done_testing;
