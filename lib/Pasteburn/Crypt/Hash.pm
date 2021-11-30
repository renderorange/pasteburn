package Pasteburn::Crypt::Hash;

use strictures version => 2;

use Crypt::PBKDF2;

our $VERSION = '0.005';

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

=pod

=head1 NAME

Pasteburn::Crypt::Hash - secure string hashing and validation

=head1 SYNOPSIS

 use Pasteburn::Crypt::Hash;

 my $crypt = Pasteburn::Crypt::Hash->new();

 my $hash  = $crypt->generate( string => $string );
 my $valid = $crypt->validate( hash => $hash, string => $string );

=head1 DESCRIPTION

This module provides secure string validation and hashing for storing strings.

=head1 SUBROUTINES/METHODS

=head2 new

=head3 ARGUMENTS

None.

=head3 RETURNS

A C<Pasteburn::Crypt::Hash> object.

=head2 generate

Method to generate hashed strings.

=head3 ARGUMENTS

=over

=item string

The plain text string for hashing.

=back

=head3 RETURNS

The hashed string for storage into the database.

=head2 validate

Method to validate hashed strings with plaintext strings.

=head3 ARGUMENTS

=over

=item hash

The hashed string to use to validate.

=item string

The plain text string to validate.

=back

=head2 RETURNS

1 or undef if the string matches the hash.

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=cut
