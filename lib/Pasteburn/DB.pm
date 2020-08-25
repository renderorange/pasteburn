package Pasteburn::DB;

use strictures version => 2;

use Pasteburn::Config;

use Cwd ();
use DBI;

our $VERSION = '0.001';

sub connect_db {
    my ( $dsn, $user, $password ) = load();
    my $dbh = DBI->connect(
        $dsn, $user,
        $password,
        {   PrintError       => 0,
            RaiseError       => 1,
            AutoCommit       => 1,
            FetchHashKeyName => 'NAME_lc',
        }
    ) or die("connect db: $DBI::errstr\n");

    return $dbh;
}

sub load {
    my $conf = Pasteburn::Config->get();

    if ( $conf->{database}{type} eq 'sqlite' ) {
        my $module_path = Cwd::realpath(__FILE__);
        $module_path =~ s/\w+\.pm//;
        my $db = Cwd::realpath( $module_path . '/../../db/pasteburn.sqlite3' );

        unless ( -f $db ) {
            die "$db is not readable";
        }

        return ( "dbi:SQLite:dbname=$db", undef, undef );
    }
    elsif ( $conf->{database}{type} eq 'mysql' ) {
        return (
            "dbi:mysql:database=" . $conf->{database}{dbname} . ";host=" . $conf->{database}{hostname} . ";port=" . $conf->{database}{port},
            $conf->{database}{username}, $conf->{database}{password}
        );
    }
}

1;

=pod

=head1 NAME

Pasteburn::DB - creates and connects to the database handle

=head1 SYNOPSIS

 use Pasteburn::DB ();

 # as a class method
 class_has _dbh => (
     is      => 'rwp',
     default => sub {
         Pasteburn::DB::connect_db()
     },
 );

 my $dbh = $class->_dbh;

=head1 DESCRIPTION

This module provides methods for other modules to connect to the database.

=head1 SUBROUTINES/METHODS

=head2 connect_db

=head3 ARGUMENTS

None.

=head3 RETURNS

The DBI db database handle.

=head2 load

=head3 ARGUMENTS

None.

=head3 RETURNS

The C<dsn>, C<user>, and C<password> strings, depending on the database type as defined in the config.

=head3 CONFIGURATION

C<connect_db> reads the database connection details from the C<.pasteburnrc> file, loaded through C<Pasteburn::Config>.

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=cut
