use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/../../../lib", "$FindBin::RealBin/../../lib";
use Pasteburn::Test;

my $class = 'Pasteburn::Config';
use_ok( $class );

my $config_expected = {
    cookie => {
        secret_key => 'notdefault',
    },
};

HAPPY_PATH: {
    note( 'happy path' );

    lives_ok { Pasteburn::Config::_validate( $config_expected ) }
        'expected keys and values all validate';
}

EXCEPTIONS: {
    note( 'exceptions' );

    subtest 'dies if missing any of the config keys' => sub {
        plan tests => 1;

        foreach my $required ( keys %{ $config_expected } ) {
            my $stored = delete $config_expected->{ $required };

            dies_ok { Pasteburn::Config::_validate( $config_expected ) }
                "dies if config is missing $required key";

            $config_expected->{ $required } = $stored;
        }
    };

    subtest 'dies if missing any of the config sub keys' => sub {
        plan tests => 1;

        foreach my $required ( keys %{ $config_expected } ) {
            foreach my $required_sub_key ( keys %{ $config_expected->{$required} } ) {
                my $stored = delete $config_expected->{$required}{$required_sub_key};

                dies_ok { Pasteburn::Config::_validate( $config_expected ) }
                    "dies if config is missing $required $required_sub_key key";

                $config_expected->{$required}{$required_sub_key} = $stored;
            }
        }
    };
}

done_testing;
