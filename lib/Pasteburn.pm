package Pasteburn;

use Dancer2 appname => 'pasteburn';

use Time::Piece;
use HTTP::Status ();

use Pasteburn::Controller::Root   ();
use Pasteburn::Controller::Secret ();
use Pasteburn::Controller::About  ();

our $VERSION = '0.002';

BEGIN {
    require Pasteburn::Config;

    my $conf = Pasteburn::Config->get();
    config->{engines}{session}{Cookie}{secret_key} = $conf->{cookie}{secret_key};

    unless ( config->{engines}{session}{Cookie}{secret_key} ) {
        die("FATAL: session Cookie secret_key is not set");
    }

    set views  => config->{appdir} . 'views';
    set footer => $conf->{footer};

    unless ( config->{views} ) {
        die("FATAL: views is not set");
    }
}

hook before => sub {
    my $app = shift;

    my $time            = localtime;
    my $now             = $time->epoch;
    my $session_secrets = session->read('secrets');

    foreach my $session_id ( keys %{$session_secrets} ) {
        if ( $session_secrets->{$session_id}{created_at} + ( 86400 * 7 ) <= $now ) {
            delete $session_secrets->{$session_id};
        }
    }
    session->write( 'secrets', $session_secrets );
};

any qr{.*} => sub {
    my $app = shift;

    my $template_params = {
        route   => request->path,
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

Pasteburn is built using the L<Dancer2 web framework|https://metacpan.org/pod/Dancer2> and L<Skeleton CSS boilerplate|https://github.com/dhg/Skeleton>.

=head1 CONFIGURATION

An example configuration file, C<config.ini.example>, is provided in the project root directory.

To set up the configuration file, copy the example into one of the following locations:

=over

=item C<$ENV{HOME}/.config/pasteburn/config.ini>

=item C</etc/pasteburn/config.ini>

=back

After creating the file, edit and update the values accordingly.

B<NOTE:> If the C<$ENV{HOME}/.config/pasteburn/> directory exists, C<config.ini> will be loaded from there regardless of a config file in C</etc/pasteburn/>.

=head2 REQUIRED KEYS

=over

=item cookie

The C<cookie> section key is required, and C<secret_key> option key within it.

 [cookie]
 secret_key = default

=item footer

The C<footer> section key is required, and C<links> option key within it.

 [footer]
 links = 1

=back

=head1 COPYRIGHT AND LICENSE

Pasteburn is Copyright (c) 2021 Blaine Motsinger under the MIT license.

Skeleton CSS is Copyright (c) 2011-2014 Dave Gamache under the MIT license.

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=cut
