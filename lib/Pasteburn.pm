package Pasteburn;

use Dancer2 appname => 'pasteburn';

use Time::Piece;
use HTTP::Status ();

use Pasteburn::Controller::Root   ();
use Pasteburn::Controller::Secret ();
use Pasteburn::Controller::About  ();

our $VERSION = '0.001';

BEGIN {
    require Pasteburn::Config;

    my $conf = Pasteburn::Config->get();
    config->{engines}{session}{Cookie}{secret_key} = $conf->{cookie}{secret_key};

    unless ( config->{engines}{session}{Cookie}{secret_key} ) {
        die("FATAL: session Cookie secret_key is not set");
    }

    set views => config->{appdir} . 'views';

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
        my $created_at = $session_secrets->{$session_id};
        if ( $created_at + ( 86400 * 7 ) <= $now ) {
            delete $session_secrets->{$session_id};
        }
    }
    session->write( 'secrets', $session_secrets );
};

any qr{.*} => sub {
    my $app = shift;

    my $template_params = {
        route   => request->path,
        message => 'That resource was not found',
    };

    response->{status} = HTTP::Status::HTTP_NOT_FOUND;
    return template error => $template_params;
};

hook on_route_exception => sub {
    my $app       = shift;
    my $exception = shift;

    my $template_params = {
        route   => request->path,
        message => 'Whoops, there was an error on our end',
    };

    log( 'error', $exception );
    response->{status} = HTTP::Status::HTTP_INTERNAL_SERVER_ERROR;
    return template error => $template_params;
};

1;

__END__

=pod

=head1 NAME

Pasteburn - Sharable, encrypted, ephemeral pastebin.

=head1 DESCRIPTION

Pasteburn is a web application for encrypting and sharing secret
content.

Using a secret passphrase you provide, Pasteburn encrypts your message
then provides a unique link for you to share. Whoever you share the link
and passphrase with can then decrypt and read your message.

Secret messages can only be decrypted one time using the secret
passphrase and are automatically deleted if not viewed within 7 days.

Pasteburn is written in Perl using the Dancer2 framework.

=head1 COPYRIGHT AND LICENSE

MIT License

Copyright (c) 2020 Blaine Motsinger

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Skeleton CSS is Copyright (c) 2011-2014 Dave Gamache under the MIT
license.

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=cut
