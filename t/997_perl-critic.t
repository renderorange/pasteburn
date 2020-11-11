use strict;
use warnings;

use FindBin;
use File::Spec;
use Test::More;

unless ( $ENV{TEST_AUTHOR} ) {
    my $msg = 'Author test. Set $ENV{TEST_AUTHOR} to a true value to run.';
    plan( skip_all => $msg );
}

eval { require Test::Perl::Critic; };

if ($@) {
    my $msg = 'Test::Perl::Critic required to criticise code';
    plan( skip_all => $msg );
}

my $rcfile = File::Spec->catfile( "$FindBin::RealBin/../", '.perlcriticrc' );
Test::Perl::Critic->import( -profile => $rcfile );

all_critic_ok("$FindBin::RealBin/../lib");
