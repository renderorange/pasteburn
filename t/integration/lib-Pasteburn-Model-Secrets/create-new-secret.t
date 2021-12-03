use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/../../lib", "$FindBin::RealBin/../../../lib";
use Pasteburn::Test;
use Pasteburn::Model::Secrets;

my $secret     = 'mysecret';
my $passphrase = 'mypassphrase';
my $secret_obj = Pasteburn::Model::Secrets->new( secret => $secret, passphrase => $passphrase );

ok( $secret_obj->passphrase eq $passphrase, 'secret object before storing contains unencoded passphrase' );
ok( $secret_obj->secret eq $secret, 'secret object before storing contains unencoded secret' );

ok( !$secret_obj->id, 'secret object before storing does not contain id' );
ok( !$secret_obj->created_at, 'secret object before storing does not contain created_at' );

my $ret = $secret_obj->store;
ok( $ret, 'store was successful' );

ok( $secret_obj->passphrase ne $passphrase, 'secret object after storing contains encoded passphrase' );
ok( $secret_obj->secret ne $secret, 'secret object after storing contains encoded secret' );

ok( $secret_obj->id, 'secret object after storing contains id' );
ok( $secret_obj->created_at, 'secret object after storing contains created_at' );

my $secret_from_db = $Pasteburn::Test::dbh->selectrow_hashref( "select * from secrets where id = ?", undef, ( $secret_obj->id ) );

ok( $secret_obj->passphrase eq $secret_from_db->{passphrase}, 'secret object and db match passphrase' );
ok( $secret_obj->secret eq $secret_from_db->{secret}, 'secret object and db match secret' );

ok( $secret_obj->id eq $secret_from_db->{id}, 'secret object and db match id' );
ok( $secret_obj->created_at eq $secret_from_db->{created_at}, 'secret object and db match created_at' );

done_testing;
