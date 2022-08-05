use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/../../lib", "$FindBin::RealBin/../../../lib";
use Pasteburn::Test;
use Pasteburn::Model::Secrets;

my $secret     = 'mysecret';
my $passphrase = 'mypassphrase';
my $new_secret_obj = Pasteburn::Model::Secrets->new( secret => $secret, passphrase => $passphrase );
ok( $new_secret_obj->store, 'stored new secret' );

my $retrieved_secret_obj = Pasteburn::Model::Secrets->get( id => $new_secret_obj->id );
is( $retrieved_secret_obj->id, $new_secret_obj->id, 'retrieved and stored secret objects match id' );
is( $retrieved_secret_obj->passphrase, $new_secret_obj->passphrase, 'retrieved and stored secret objects match passphrase' );
is( $retrieved_secret_obj->secret, $new_secret_obj->secret, 'retrieved and stored secret objects match secret' );
is( $retrieved_secret_obj->created_at, $new_secret_obj->created_at, 'retrieved and stored secret objects match created_at' );

done_testing;
