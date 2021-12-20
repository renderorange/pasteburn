package Pasteburn::Crypt::Storage;

use strictures version => 2;

use Session::Storage::Secure ();
use Time::Piece;

our $VERSION = '0.014';

sub new {
    my $class = shift;
    my $arg   = {
        passphrase => undef,
        @_,
    };

    unless ( $arg->{passphrase} ) {
        die "passphrase argument is required\n";
    }

    my $self = { _store_obj => Session::Storage::Secure->new( secret_key => $arg->{passphrase} ), };

    return bless $self, $class;
}

sub encode {
    my $self = shift;
    my $arg  = {
        secret => undef,
        @_,
    };

    unless ( $arg->{secret} ) {
        die "secret argument is required\n";
    }

    my $time    = localtime;
    my $expires = $time->epoch + ( 86400 * 7 );

    return $self->{_store_obj}->encode( $arg->{secret}, $expires );
}

sub decode {
    my $self = shift;
    my $arg  = {
        secret => undef,
        @_,
    };

    unless ( $arg->{secret} ) {
        die "secret argument is required\n";
    }

    return $self->{_store_obj}->decode( $arg->{secret} );
}

1;

=pod

=head1 NAME

Pasteburn::Crypt::Storage - secure string hashing and validation

=head1 SYNOPSIS

 use Pasteburn::Crypt::Storage;

 my $store = Pasteburn::Crypt::Storage->new(
     passphrase => $passphrase,
 );

 my $encoded = $store->encode( secret => $secret );
 my $decoded = $store->decode( secret => $encoded );

=head1 DESCRIPTION

This module provides secure encoding and decoding for storing strings.

=head1 SUBROUTINES/METHODS

=head2 new

=head3 ARGUMENTS

=over

=item passphrase

The passphrase to use to encode and decode.

=back

=head3 RETURNS

A C<Pasteburn::Crypt::Storage> object.

=head2 encode

Method to encode strings.

=head3 ARGUMENTS

=over

=item secret

The plain text string for encrypting.

=back

=head3 RETURNS

The encoded string for storage into the database.

=head2 decode

Method to decode strings.

=head3 ARGUMENTS

=over

=item secret

The encoded string for decrypting.

=back

=head2 RETURNS

The decoded string.

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=cut
