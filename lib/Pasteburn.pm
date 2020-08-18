package Pasteburn;

use Dancer2 appname => 'pasteburn';

use Time::Piece;
use HTTP::Status ();

use Pasteburn::Controller::Root   ();
use Pasteburn::Controller::Secret ();

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

Pasteburn is a web application for encrypting and sharing ephemeral content.

Content is automatically deleted when decrypted or stored a maximum of 7 days, then automatically deleted.

Pasteburn is written in Perl using the Dancer2 framework.

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2020 by Blaine Motsinger.

This is free software; you can redistribute it and/or modify it under the same terms as the Perl 5 programming language system itself.

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=cut
