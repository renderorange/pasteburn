use strictures version => 2;

use Time::Piece;
use Try::Tiny;

use Pasteburn::DB ();

my $time = localtime;
my $now  = $time->epoch;

my $dbh = Pasteburn::DB::connect_db();
my $sql = qq{
    DELETE FROM secrets
    WHERE created_at + (86400 * 7) <= $now
    };

my $result = try {
    return $dbh->do( $sql );
}
catch {
    my $exception = $_;
    die "delete secrets failed: $exception";
};
