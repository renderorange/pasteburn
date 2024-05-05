use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/../../lib", "$FindBin::RealBin/../../../lib";
use Pasteburn::Test;
use Pasteburn::Model::Secrets;

SCRUB_SECRET_ENABLED: {
    note( 'scrub secret enabled' );
    my $secret_non_html = 'blaine was here text';
    my $secret     = '</textarea><script>blaine was here script</script>' . $secret_non_html;
    my $passphrase = 'mypassphrase';
    my $secret_obj = Pasteburn::Model::Secrets->new( secret => $secret, passphrase => $passphrase );

    # here we're intentionally not scrubbing the incoming secret because we need to ensure
    # decoding a secret with html works correctly.
    ok( $secret_obj->store, 'stored new secret' );

    my $decoded_secret = $secret_obj->decode_secret( passphrase => $passphrase, scrub => 1 );
    isnt( $decoded_secret, $secret, "returned secret doesn't match" );
    is( $decoded_secret, $secret_non_html, 'returned secret only contains the non-html string' );
}

SCRUB_SECRET_DISABLED: {
    note( 'scrub secret disabled' );
    my $secret_non_html = 'blaine was here text';
    my $secret     = '</textarea><script>blaine was here script</script>' . $secret_non_html;
    my $passphrase = 'mypassphrase';
    my $secret_obj = Pasteburn::Model::Secrets->new( secret => $secret, passphrase => $passphrase );

    # here we're intentionally not scrubbing the incoming secret because we need to ensure
    # decoding a secret with html works correctly.
    ok( $secret_obj->store, 'stored new secret' );

    my $decoded_secret = $secret_obj->decode_secret( passphrase => $passphrase, scrub => 0 );
    is( $decoded_secret, $secret, 'returned secret contains the html and non-html string parts' );
}

done_testing;
