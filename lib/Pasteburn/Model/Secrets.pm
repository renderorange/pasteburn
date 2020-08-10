package Pasteburn::Model::Secrets;

use strictures version => 2;

use Types::Common::String qw{ NonEmptyStr };
use DateTime::Format::Strptime ();

use Pasteburn::DB ();

use Try::Tiny;
use Scalar::Util ();

use Pasteburn::Crypt::Hash    ();
use Pasteburn::Crypt::Storage ();
use Digest::SHA               ();

use Moo;
use MooX::ClassAttribute;
use namespace::clean;

our $VERSION = '0.001';

has id => (
    is     => 'rwp',
    isa    => NonEmptyStr,
    writer => '_set_id',
);

has passphrase => (
    is       => 'rw',
    required => 1,
    isa      => NonEmptyStr,
    writer   => '_set_passphrase',
);

has secret => (
    is       => 'rw',
    required => 1,
    isa      => NonEmptyStr,
    writer   => '_set_secret',
);

has created_at => (
    is  => 'rwp',
    isa => sub {
        my $strp = DateTime::Format::Strptime->new(
            pattern  => '%Y-%m-%d %H:%M:%S',
            on_error => 'undef'
        );
        unless ( $strp->parse_datetime( $_[0] ) ) {
            die "not a valid created_at type";
        }
    },
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
            ( id, passphrase, secret )
        VALUES
            ( ?, ?, ? )
        };

    my @bind_values = ( $id, $hashed_passphrase, $encoded_secret );

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

    my $crypt = Pasteburn::Crypt::Hash->new();
    my $hash  = $crypt->generate( string => rand . localtime . rand );

    return Digest::SHA::sha256_hex($hash);
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

    unless ( $arg->{passphrase} ) {
        die "passphrase is required";
    }

    # this should never happen, but leaving it here just in case.
    unless ( defined $self->passphrase ) {
        die "passphrase is not set";
    }

    my $crypt = Pasteburn::Crypt::Hash->new();
    return $crypt->validate( hash => $self->passphrase, string => $arg->{passphrase} );
}

1;
