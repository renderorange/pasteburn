use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/../../../lib", "$FindBin::RealBin/../../lib";
use Pasteburn::Test;

my $class = 'Pasteburn::Crypt::Hash';
use_ok( $class );

my $crypt = $class->new();
isa_ok( $crypt, $class );

my @methods = qw(
    generate
    validate
);

can_ok( $class, $_ ) foreach @methods;

done_testing();
