use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/lib", "$FindBin::RealBin/../lib";
use Pasteburn::Test;

my $config = {
    cookie => {
        secret_key => 'testing',
    },
    footer => {
        links => 1,
    },
};

Pasteburn::Test::override(
    package => 'Pasteburn::Config',
    name    => 'get',
    subref  => sub { return $config },
);

unless ( $ENV{TEST_AUTHOR} ) {
    my $msg = 'Author test. Set $ENV{TEST_AUTHOR} to a true value to run.';
    plan( skip_all => $msg );
}

eval { require Test::Pod::Coverage; };

if ($@) {
    my $msg = 'Test::Pod::Coverage required to criticise code';
    plan( skip_all => $msg );
}

Test::Pod::Coverage::all_pod_coverage_ok();
