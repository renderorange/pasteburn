package Pasteburn::Crypt::Hash;

use strictures version => 2;

use Crypt::PBKDF2;

our $VERSION = '0.001';

sub new {
    my $class = shift;

    my $self = {
        _hash_obj => Crypt::PBKDF2->new(
            hash_class => 'HMACSHA1',
            iterations => 1000,
            output_len => 20,
            salt_len   => 124,
        ),
    };

    return bless $self, $class;
}

sub generate {
    my $self = shift;
    my $arg  = {
        string => undef,
        @_,
    };

    unless ( $arg->{string} ) {
        die "string is required\n";
    }

    return $self->{_hash_obj}->generate( $arg->{string} );
}

sub validate {
    my $self = shift;
    my $arg  = {
        hash   => undef,
        string => undef,
        @_,
    };

    foreach my $required ( keys %{$arg} ) {
        unless ( $arg->{$required} ) {
            die "$required is required\n";
        }
    }

    return $self->{_hash_obj}->validate( $arg->{hash}, $arg->{string} );
}

1;
