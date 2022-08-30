package Pasteburn::Model::Secrets;

use strictures version => 2;

use Pasteburn::DB ();

use Time::Piece;
use Try::Tiny;
use Scalar::Util ();

use Pasteburn::Crypt::Hash    ();
use Pasteburn::Crypt::Storage ();
use Crypt::Random             ();
use Digest::SHA               ();

use Moo;
use MooX::ClassAttribute;
use namespace::clean;

our $VERSION = '0.021';

has id => (
    is  => 'rwp',
    isa => sub {
        if ( length $_[0] != 64 ) {
            die "id must have a length == 64\n";
        }
    },
    writer => '_set_id',
);

has passphrase => (
    is       => 'rw',
    required => 1,
    isa      => sub {
        if ( !defined $_[0] ) {
            die "passphrase must be a non empty string\n";
        }
    },
    writer => '_set_passphrase',
);

has secret => (
    is       => 'rw',
    required => 1,
    isa      => sub {
        if ( !defined $_[0] ) {
            die "secret must be a non empty string\n";
        }
    },
    writer => '_set_secret',
);

has created_at => (
    is  => 'rwp',
    isa => sub {
        if ( length $_[0] != 10 ) {
            die "created_at must have a length == 10\n";
        }
    },
    writer => '_set_created_at',
);

class_has _dbh => (
    is      => 'rwp',
    default => sub {
        Pasteburn::DB::connect_db()
    },
);

sub get {
    my $class = shift;
    my $arg   = {
        id => undef,
        @_,
    };

    my $sql = q{
        SELECT
            id,
            passphrase,
            secret,
            created_at
        FROM
            secrets
    };

    my ( @where, @bind_values );

    foreach my $key ( keys %{$arg} ) {
        unless ( defined $arg->{$key} ) {
            next;
        }

        push @where,       "$key = ?";
        push @bind_values, $arg->{$key};
    }

    if ( scalar @where ) {
        $sql .= ' WHERE ' . join " AND ", @where;
    }

    my $secret_hashref = $class->_dbh->selectrow_hashref( $sql, undef, @bind_values );

    unless ($secret_hashref) {
        return;
    }

    return $class->new( %{$secret_hashref} );
}

sub store {
    my $self = shift;

    foreach my $attribute ( 'passphrase', 'secret' ) {
        unless ( defined $self->{$attribute} ) {
            die "$attribute is required";
        }
    }

    my $id = $self->_generate_id;

    my $crypt_hash        = Pasteburn::Crypt::Hash->new();
    my $hashed_passphrase = $crypt_hash->generate( string => $self->passphrase );

    my $crypt_storage  = Pasteburn::Crypt::Storage->new( passphrase => $self->passphrase );
    my $encoded_secret = $crypt_storage->encode( secret => $self->secret );

    my $sql = q{
        INSERT INTO secrets
            ( id, passphrase, secret, created_at )
        VALUES
            ( ?, ?, ?, ? )
        };

    my $time        = localtime;
    my @bind_values = ( $id, $hashed_passphrase, $encoded_secret, $time->epoch );

    my $result = try {
        return $self->_dbh->do( $sql, undef, @bind_values );
    }
    catch {
        my $exception = $_;
        die "store secret failed: $exception";
    };

    # set id into the object so we can _update_object using it as a select value.
    $self->_set_id($id);

    $self->_update_object;

    return $result;
}

sub _generate_id {
    my $self = shift;

    unless ( Scalar::Util::blessed($self) ) {
        die "_generate_id must be called as an object method";
    }

    return Digest::SHA::sha256_hex( Crypt::Random::makerandom( Size => 512, Strength => 0 ) );
}

sub _update_object {
    my $self = shift;

    unless ( Scalar::Util::blessed($self) ) {
        die "_update_object must be called as an object method";
    }

    # always update the object with the data from the database.
    # since the data is encrypted and hashed, we need that in the object
    # after it's stored, rather than the data it was created with.
    my @columns = (qw{ id passphrase secret created_at });

    my $query = 'select ' . ( join ', ', @columns ) . ' from secrets where id = ?';

    my $secret_hashref = $self->_dbh->selectrow_hashref( $query, undef, $self->id );

    foreach my $update (@columns) {
        my $setter = '_set_' . $update;
        $self->$setter( $secret_hashref->{$update} );
    }

    return;
}

sub validate_passphrase {
    my $self = shift;
    my $arg  = {
        passphrase => undef,
        @_,
    };

    unless ( Scalar::Util::blessed($self) ) {
        die "validate_passphrase must be called as an object method";
    }

    unless ( $self->id ) {
        die "validate_passphrase cannot be run for a nonexistent secret";
    }

    unless ( defined $arg->{passphrase} ) {
        die "passphrase is required";
    }

    # if the secret is stored with an empty string as passphrase, there is still
    # a hashed passphrase stored in the object and db.
    # the code up to this point will allow empty string submitted from the interface,
    # but not allow an undef to be stored.
    # although unlikely to fail, still verify the hashed passphrase is in the object.
    unless ( defined $self->passphrase ) {
        die "passphrase is not set";
    }

    my $crypt = Pasteburn::Crypt::Hash->new();
    return $crypt->validate( hash => $self->passphrase, string => $arg->{passphrase} );
}

sub decode_secret {
    my $self = shift;
    my $arg  = {
        passphrase => undef,
        @_,
    };

    unless ( Scalar::Util::blessed($self) ) {
        die "decode_secret must be called as an object method";
    }

    unless ( $self->id ) {
        die "decode_secret cannot be run for a nonexistent secret";
    }

    unless ( defined $arg->{passphrase} ) {
        die "passphrase is required";
    }

    my $crypt_storage = Pasteburn::Crypt::Storage->new( passphrase => $arg->{passphrase} );
    return $crypt_storage->decode( secret => $self->secret );
}

sub delete_secret {
    my $self = shift;

    unless ( Scalar::Util::blessed($self) ) {
        die "delete_secret must be called as an object method";
    }

    unless ( $self->id ) {
        die "delete_secret cannot be run for a nonexistent secret";
    }

    my $sql = q{
        DELETE FROM secrets
        WHERE id = ?
        };

    my $result = try {
        return $self->_dbh->do( $sql, undef, $self->id );
    }
    catch {
        my $exception = $_;
        die "delete secret failed: $exception";
    };

    undef $self;
    return $result;
}

1;

__END__

=pod

=head1 NAME

Pasteburn::Model::Secrets - data access layer for Secrets

=head1 SYNOPSIS

 use Pasteburn::Model::Secrets ();

 my $secret_obj = Pasteburn::Model::Secrets->new( secret => $secret, passphrase => $passphrase );
 $secret_obj->store;

 my $secret_obj = Pasteburn::Model::Secrets->get( id => $id );
 $secret_obj->validate_passphrase( passphrase => $passphrase );
 my $decoded_secret = $secret_obj->decode_secret( passphrase => $passphrase );

 $secret_obj->delete_secret;

=head1 DESCRIPTION

C<Pasteburn::Model::Secrets> provides an object oriented data layer for interacting with the secrets table.

=head1 SUBROUTINES/METHODS

=head2 new

Class constructor for the Pasteburn::Model::Secrets object to create new secrets entries.

=head3 ARGUMENTS

=over

=item secret

=item passphrase

=back

=head3 RETURNS

Pasteburn::Model::Secrets object.

=head2 get

Class constructor for the Pasteburn::Model::Secrets object to get secrets entries.

=head3 ARGUMENTS

=over

=item id

=back

=head3 RETURNS

Secrets object containing the columns for the row.

=head2 store

Object method to write the object attributes to the secrets table.

Encodes the secret and hashes the passphrase before storing.

=head3 ARGUMENTS

None.

=head3 RETURNS

The result of the database action.

The DBI action is processed with DBI->do, returning the number of updated or inserted rows.

The store method returns the return from the do method, which can be checked for truthy if success.

=head2 _generate_id

Interal method to generate the sha256_hex string to use as id.

=head3 ARGUMENTS

None.

=head3 RETURNS

sha256_hex string.

=head2 _update_object

Internal method to update the secret object with columns from the database.

=head3 ARGUMENTS

None.

=head3 RETURNS

Nothing.

The retrieved columns from the secret record in the database are updated in the object.

=head2 validate_passphrase

Object method to validate the submitted passphrase with the stored hashed passphrase.

=head3 ARGUMENTS

=over

=item passphrase

=back

=head3 RETURNS

True or false if the string matches or not.

=head2 decode_secret

Object method to decode the stored secret using the submitted passphrase.

=head3 ARGUMENTS

=over

=item passphrase

=back

=head3 RETURNS

The decoded secret or undef if decoding is successful or unsuccessful.

=head2 delete_secret

Object method to delete the stored secret row and undef the object.

=head3 ARGUMENTS

None.

=head3 RETURNS

The result of the database operation to delete the row.

=head1 OBJECT ATTRIBUTES

Apart from the arguments in the constructor, the object contains the following attributes.

The attributes below all correspond to columns in the secrets table.

=over

=item id

=item passphrase

=item secret

=item created_at

=back

=head1 CLASS ATTRIBUTES

Class attributes not corresponding to a row in the secrets table.

=over

=item _dbh

Available database handle.

=back

=head1 COPYRIGHT AND LICENSE

MIT License

Copyright (c) 2021 Blaine Motsinger

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

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=cut
