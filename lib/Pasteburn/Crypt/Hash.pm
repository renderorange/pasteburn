package Pasteburn::Crypt::Hash;

use strictures version => 2;

use Crypt::Random              ();
use Crypt::Eksblowfish::Bcrypt ();
use Digest::SHA                ();
use Encode                     ();

our $VERSION = '0.019';

sub new {
    my $class = shift;

    my $self = { cost => 12, };

    return bless $self, $class;
}

sub generate {
    my $self = shift;
    my $arg  = {
        string => undef,
        salt   => undef,
        @_,
    };

    unless ( $arg->{string} ) {
        die "string is required\n";
    }

    my $salt;
    if ( $arg->{salt} ) {
        $salt = Crypt::Eksblowfish::Bcrypt::de_base64( $arg->{salt} );
    }
    else {
        $salt = Crypt::Random::makerandom_octet( Length => 16 );
    }

    # TODO: if we want to support the ability to upgrade cost in the future
    # without invalidating existing secrets, add cost as an arg that can be read
    # from the stored string.  if passed, use cost to generate the string, else
    # use the default in the object.
    my $hash = Crypt::Eksblowfish::Bcrypt::bcrypt_hash(
        {   key_nul => 1,
            cost    => $self->{cost},
            salt    => $salt,
        },
        Digest::SHA::sha512( Encode::encode( 'UTF-8', $arg->{string} ) )
    );

    return join( q{!},
        q{}, 'bcrypt',
        sprintf( '%02d', $self->{cost} ),
        Crypt::Eksblowfish::Bcrypt::en_base64($salt) . Crypt::Eksblowfish::Bcrypt::en_base64($hash) );
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

    my ( undef, $method, @parts ) = split /!/, $arg->{hash};
    my $salt = substr( $parts[1], 0, 22 );

    my $input = $self->generate( string => $arg->{string}, salt => $salt );

    return unless length($input) == length( $arg->{hash} );

    my $match = 1;
    foreach my $i ( 0 .. length($input) - 1 ) {
        $match &= ( substr( $input, $i, 1 ) eq substr( $arg->{hash}, $i, 1 ) ) ? 1 : 0;
    }

    return $match;
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

=item salt

The salt to use for hashing the string.

The C<validate> method passes the salt into generate to validate the string.

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
