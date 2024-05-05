use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/../../lib", "$FindBin::RealBin/../../../lib";
use Pasteburn::Test;

use HTTP::Request ();

my $config = {
    secret => {
        age => 1,
        scrub => 1,
    },
    passphrase => {
        allow_blank => 1,
    },
    cookie => {
        secret_key => 'testing',
    },
    footer => {
        links => 1,
    },
};

my $test = Pasteburn::Test::create_test_app(
    config => $config,
);

my $method   = 'GET';
my $endpoint = '/secret';

my $headers = [];
my $request = HTTP::Request->new( $method, $endpoint, $headers );

my $response = $test->request( $request );

like( $response->content, qr/Create a secret message/, 'secret page is loaded' );

$method   = 'POST';
$endpoint = '/secret';

$headers = [ 'Content-Type' => 'application/x-www-form-urlencoded' ];
my $data = 'passphrase=&secret=test';
$request = HTTP::Request->new( $method, $endpoint, $headers, $data );

note( 'submitted post' );
$response = $test->request( $request );

is( $response->code, 302, 'response is 302 redirect' );
like( $response->header('Location'), qr/\/secret\/\w+$/, 'response location header contains the new secret id' );

my ( $secret_id ) = $response->header('Location') =~ /\/secret\/(\w+)$/;
my $secret_from_db = $Pasteburn::Test::dbh->selectrow_hashref( "select * from secrets where id = ?", undef, ( $secret_id ) );

ok( $secret_from_db->{id}, 'secret exists in the db' );

done_testing;
