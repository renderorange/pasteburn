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
my $secret_non_html = 'blaine was here text';
my $secret = '</textarea><script>blaine was here script</script>' . $secret_non_html;

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

my $regex = 'readonly>' . $secret_non_html . '<\/textarea';
like( $response->content, qr/$regex/, 'response content contains expected decoded secret' );

done_testing;
