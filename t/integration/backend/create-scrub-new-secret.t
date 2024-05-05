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

    ok( $secret_obj->store( scrub => 1 ), 'store was successful' );

    # here we're intentionally not scrubbing the outgoing secret because we need to ensure
    # scrubbing the secret inbound works correctly.
    my $decoded_secret = $secret_obj->decode_secret( passphrase => $passphrase );
    is( $decoded_secret, $secret_non_html, 'returned secret only contains the non-html string' )
}

SCRUB_SECRET_DISABLED: {
    note( 'scrub secret disabled' );
    my $secret_non_html = 'blaine was here text';
    my $secret     = '</textarea><script>blaine was here script</script>' . $secret_non_html;
    my $passphrase = 'mypassphrase';
    my $secret_obj = Pasteburn::Model::Secrets->new( secret => $secret, passphrase => $passphrase );

    ok( $secret_obj->store( scrub => 0 ), 'store was successful' );

    # here we're intentionally not scrubbing the outgoing secret because we need to ensure
    # scrubbing the secret inbound works correctly.
    my $decoded_secret = $secret_obj->decode_secret( passphrase => $passphrase );
    is( $decoded_secret, $secret, 'returned secret contains the html and non-html string parts' );
}

done_testing;
