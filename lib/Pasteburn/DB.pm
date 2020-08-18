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
