package Pasteburn;

use Dancer2 appname => 'pasteburn';

use HTTP::Status ();

use Pasteburn::Controller::Root   ();
use Pasteburn::Controller::Secret ();
use Pasteburn::Controller::About  ();

our $VERSION = '0.021';

BEGIN {
    require Pasteburn::Config;

    my $conf = Pasteburn::Config->get();
    config->{engines}{session}{Cookie}{secret_key} = $conf->{cookie}{secret_key};

    unless ( config->{engines}{session}{Cookie}{secret_key} ) {
        die("FATAL: session Cookie secret_key is not set");
    }

    set secret     => $conf->{secret};
    set passphrase => $conf->{passphrase};

    set views  => config->{appdir} . 'views';
    set footer => $conf->{footer};

    unless ( config->{views} ) {
        die("FATAL: views is not set");
    }
}

hook before => sub {
    my $app = shift;

    my $session_secrets = session->read('secrets');

    foreach my $session_id ( keys %{$session_secrets} ) {
        my $secret_obj = Pasteburn::Model::Secrets->get( id => $session_id );
        unless ($secret_obj) {
            delete $session_secrets->{$session_id};
        }
    }
    session->write( 'secrets', $session_secrets );
};

any qr{.*} => sub {
    my $app = shift;

    my $template_params = {
        footer  => config->{footer},
        message => 'That resource was not found',
    };

    response->{status} = HTTP::Status::HTTP_NOT_FOUND;
    return template error => $template_params;
};

hook on_route_exception => sub {
    my $app       = shift;
    my $exception = shift;

    log( 'error', $exception );
};

sub set_session_response {
    my $response = shift;
    session->write( 'response', $response );

    return;
}

sub get_session_response {
    my $response = session->read('response') || qw{};
    session->write( 'response', undef );

    return $response;
}

1;

__END__

=pod

=head1 NAME

Pasteburn - Sharable, encrypted, ephemeral pastebin.

=head1 DESCRIPTION

Pasteburn is a web application for encrypting and sharing secret content.

Using a secret passphrase you provide, Pasteburn encrypts your message then provides a unique link for you to share. Whomever you share the link and passphrase with can then decrypt and read your message.

Secrets can't be read without the passphrase and can't be restored once they're read or deleted.

Secrets can only be decrypted one time and are deleted when decrypted. Secrets are automatically deleted if not viewed within 7 days.

Pasteburn is built using the L<Dancer2 web framework|https://metacpan.org/pod/Dancer2>, L<Skeleton CSS boilerplate|https://github.com/dhg/Skeleton>, L<clipboard.js JS library|https://clipboardjs.com>, and L<normalize.css CSS library|https://github.com/necolas/normalize.css>.

=head1 CONFIGURATION

An example configuration file, C<config.ini.example>, is provided in the examples directory.

To set up the configuration file, copy the example into one of the following locations:

=over

=item C<$ENV{HOME}/.config/pasteburn/config.ini>

=item C</etc/pasteburn/config.ini>

=back

After creating the file, edit and update the values accordingly.

B<NOTE:> If the C<$ENV{HOME}/.config/pasteburn/> directory exists, C<config.ini> will be loaded from there regardless of a config file in C</etc/pasteburn/>.

=head2 REQUIRED KEYS

=over

=item secret

The C<secret> section key is required, C<age> and C<scrub> option keys within it.

 [secret]
 age = 604800
 scrub = 1

To change the default time to expire secrets, change the C<age> value.  The value must be a positive integer.  The C<age> value is only enforced if running the C<delete_expired_secrets.pl> script, as noted below.

If C<scrub> is set to 1, HTML tags will be removed from the secret string before storing and again as it's retrieved from the database.  If set to 0, HTML tags will not be removed from the secret.

B<NOTE:> Setting C<scrub> to 0 means XSS vulnerabilities will be possible in the textarea box as it's displayed.  Disable this setting with caution.

=item passphrase

The C<passphrase> section key is required, and the C<allow_blank> option key within it.

 [passphrase]
 allow_blank = 0

The allow users to set a blank passphrase, change C<allow_blank> to C<1>.

=item cookie

The C<cookie> section key is required, and C<secret_key> option key within it.

 [cookie]
 secret_key = default

Set the C<secret_key> value to a complex random string for your installation.

=item footer

The C<footer> section key is required, and C<links> option key within it.

 [footer]
 links = 1

To disable the links in the footer, set the C<links> value to C<0>.

=back

=head1 COPYRIGHT AND LICENSE

Pasteburn is Copyright (c) 2022 Blaine Motsinger under the MIT license.

Skeleton CSS is Copyright (c) 2011-2014 Dave Gamache under the MIT license.

clipboard.js is Copyright (c) Zeno Rocha under the MIT license.

normalize.css is Copyright (c) Nicolas Gallagher and Jonathan Neal under the MIT license.

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=cut
