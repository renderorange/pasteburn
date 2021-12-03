use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/../../../lib", "$FindBin::RealBin/../../lib";
use Pasteburn::Test skip_db => 1;

my $class = 'Pasteburn::Crypt::Hash';
use_ok( $class );

CONSTRUCTOR: {
    note( 'constructor' );

    my $crypt = $class->new();
    isa_ok( $crypt, $class );

    my @methods = qw(
        generate
        validate
    );

    can_ok( $class, $_ ) foreach @methods;
}

done_testing();
