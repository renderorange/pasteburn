use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/../../lib", "$FindBin::RealBin/../../../lib";
use Pasteburn::Test;
use Pasteburn::Model::Secrets;

my $secret     = 'mysecret';
my $passphrase = '';
my $secret_obj = Pasteburn::Model::Secrets->new( secret => $secret, passphrase => $passphrase );

ok( $secret_obj->passphrase eq $passphrase, 'secret object before storing contains passphrase' );
ok( $secret_obj->secret eq $secret, 'secret object before storing contains unencoded secret' );

my $ret = $secret_obj->store;
ok( $ret, 'store was successful' );

ok( $secret_obj->passphrase ne $passphrase, 'secret object after storing contains passphrase' );
ok( $secret_obj->secret ne $secret, 'secret object after storing contains encoded secret' );

ok( $secret_obj->id, 'secret object after storing contains id' );
ok( $secret_obj->created_at, 'secret object after storing contains created_at' );

my $secret_from_db = $Pasteburn::Test::dbh->selectrow_hashref( "select * from secrets where id = ?", undef, ( $secret_obj->id ) );

ok( $secret_obj->passphrase eq $secret_from_db->{passphrase}, 'secret object and db match passphrase' );

is( $secret_obj->decode_secret( passphrase => $passphrase ), $secret, 'matching passphrase returns decoded secret' );
ok( !$secret_obj->decode_secret( passphrase => 'incorrect' ), 'not matching passphrase returns nothing' );

done_testing;
