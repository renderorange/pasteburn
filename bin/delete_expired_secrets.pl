use strictures version => 2;

use Getopt::Long ();
use Pod::Usage   ();
use Time::Piece;
use Try::Tiny;

use Pasteburn::Config ();
use Pasteburn::DB     ();

Getopt::Long::GetOptions( \my %opt, 'verbose', 'help', ) or Pod::Usage::pod2usage( -exitval => 1 );
Pod::Usage::pod2usage( -exitval => 0, -verbose => 1 ) if $opt{help};

my $time = localtime;
my $now  = $time->epoch;

my $config = Pasteburn::Config->get();
my $dbh    = Pasteburn::DB::connect_db();

my $select_sql = 'SELECT id, created_at FROM secrets WHERE created_at + ? <= ' . $now;
my @secrets    = try {
    return @{ $dbh->selectall_arrayref( $select_sql, { Slice => {} }, $config->{secret}{age} ) };
}
catch {
    my $exception = $_;
    die "select secrets failed: $exception";
};

exit unless @secrets;

my @bind_values;
foreach my $secret_hashref (@secrets) {
    print 'deleting secret id ' . $secret_hashref->{id} . "\n" if $opt{verbose};
    push @bind_values, $secret_hashref->{id};
}

my $delete_sql = 'DELETE FROM secrets WHERE id IN ( ' . ( join ', ', map {'?'} @bind_values ) . ' )';

my $result = try {
    return $dbh->do( $delete_sql, undef, @bind_values );
}
catch {
    my $exception = $_;
    die "delete secrets failed: $exception";
};

__END__

=pod

=head1 NAME

delete_expired_secrets.pl - delete secrets older than max age

=head1 SYNOPSIS

 delete_expired_secrets.pl [--verbose] [--help]

=head1 DESCRIPTION

C<delete_expired_secrets.pl> deletes secrets older than the max age as defined in the Pasteburn config.

=head1 OPTIONS

=over

=item --verbose

Print secret ids being deleted.

=item --help

Print the help menu.

=back

=cut
