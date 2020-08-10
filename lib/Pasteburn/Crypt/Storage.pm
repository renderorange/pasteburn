package Pasteburn::Crypt::Storage;

use strictures version => 2;

use Session::Storage::Secure ();
use Time::Piece;

our $VERSION = '0.001';

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
