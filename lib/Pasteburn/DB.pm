package Pasteburn::DB;

use strictures version => 2;

use Cwd ();
use DBI;

our $VERSION = '0.008';

sub connect_db {
    my $dsn = load();
    my $dbh = DBI->connect(
        $dsn, undef, undef,
        {   PrintError       => 0,
            RaiseError       => 1,
            AutoCommit       => 1,
            FetchHashKeyName => 'NAME_lc',
        }
    ) or die("connect db: $DBI::errstr\n");

    return $dbh;
}

sub load {
    my $module_path = Cwd::realpath(__FILE__);
    $module_path =~ s/\w+\.pm//;
    my $db = Cwd::realpath( $module_path . '/../../db/pasteburn.sqlite3' );

    unless ( -f $db ) {
        die "$db is not readable";
    }

    return "dbi:SQLite:dbname=$db";
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

The C<dsn> string.

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=cut
