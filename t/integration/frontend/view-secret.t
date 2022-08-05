use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/../../lib", "$FindBin::RealBin/../../../lib";
use Pasteburn::Test;
use Pasteburn::Model::Secrets;

use HTTP::Request ();

my $config = {
    secret => {
        age => 1,
    },
    passphrase => {
        allow_blank => 0,
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
my $passphrase = 'testpassphrase';
my $secret = 'testsecret';

$headers = [ 'Content-Type' => 'application/x-www-form-urlencoded' ];
my $data = 'passphrase=' . $passphrase . '&secret=' . $secret;
$request = HTTP::Request->new( $method, $endpoint, $headers, $data );

note( 'submitted post to create secret' );
$response = $test->request( $request );

my ( $secret_id ) = $response->header('Location') =~ /\/secret\/(\w+)$/;

$endpoint = '/secret/' . $secret_id;
$data = 'passphrase=' . $passphrase;
$request = HTTP::Request->new( $method, $endpoint, $headers, $data );

note( 'submitted post to view secret' );
$response = $test->request( $request );

is( $response->code, 200, 'response code is 200' );

my $regex = 'readonly>' . $secret . '<\/textarea';
like( $response->content, qr/$regex/, 'response content contains expected decoded secret' );

$method  = 'GET';
$headers = [];
$request = HTTP::Request->new( $method, $endpoint, $headers, $data );

note( 'submitted get to view deleted secret' );
$response = $test->request( $request );

is( $response->code, 302, 'response code is 302 redirect' );
like( $response->header('Location'), qr/\/secret$/, 'response location header is to secret route' );

# TODO:
# implement cookie jar functionality to allow testing session related functionality
# - get_session_response for error string if secret doesn't exist
# - secret view differences if secret was created by the viewer (author template params)

done_testing;
