use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/../../lib", "$FindBin::RealBin/../../../lib";
use Pasteburn::Test;
use Pasteburn::Model::Secrets;

my $secret     = 'mysecret';
my $passphrase = 'mypassphrase';
my $secret_obj = Pasteburn::Model::Secrets->new( secret => $secret, passphrase => $passphrase );
my $ret = $secret_obj->store;
ok( $ret, 'store was successful' );

my $explain_query_plan = <<'END_QUERY_PLAN';
EXPLAIN QUERY PLAN 
SELECT
    id
FROM
    secrets
WHERE
    id = ?
END_QUERY_PLAN

my $explain_query_plan_from_db = $Pasteburn::Test::dbh->selectrow_hashref( $explain_query_plan, undef, ( $secret_obj->id ) );
like( $explain_query_plan_from_db->{detail}, qr{idx_secrets_id}, 'explain plan lists index name is used' );

done_testing;
