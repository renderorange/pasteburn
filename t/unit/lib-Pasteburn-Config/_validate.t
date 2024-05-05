use strict;
use warnings;

use FindBin ();
use lib "$FindBin::RealBin/../../../lib", "$FindBin::RealBin/../../lib";
use Pasteburn::Test skip_db => 1;

my $class = 'Pasteburn::Config';
use_ok( $class );

my $config_expected = {
    secret => {
        age => 1,
        scrub => 1,
    },
    passphrase => {
        allow_blank => 0,
    },
    cookie => {
        secret_key => 'testing',
    },
    footer => {
        links => 1,
    },
};

HAPPY_PATH: {
    note( 'happy path' );

    lives_ok { Pasteburn::Config::_validate( $config_expected ) }
        'lives if config is valid';
}

EXCEPTIONS: {
    note( 'exceptions' );

    subtest 'dies if missing any of the config keys' => sub {
        plan tests => 4;

        foreach my $required ( keys %{ $config_expected } ) {
            my $stored = delete $config_expected->{ $required };

            dies_ok { Pasteburn::Config::_validate( $config_expected ) }
                "dies if config is missing $required key";

            $config_expected->{ $required } = $stored;
        }
    };

    subtest 'dies if missing any of the config sub keys' => sub {
        plan tests => 5;

        foreach my $required ( keys %{ $config_expected } ) {
            foreach my $required_sub_key ( keys %{ $config_expected->{$required} } ) {
                my $stored = delete $config_expected->{$required}{$required_sub_key};

                dies_ok { Pasteburn::Config::_validate( $config_expected ) }
                    "dies if config is missing $required $required_sub_key key";

                $config_expected->{$required}{$required_sub_key} = $stored;
            }
        }
    };

    subtest 'dies if secret age key does not validate value' => sub {
        plan tests => 2;

        my $secret_age = $config_expected->{secret}{age};
        foreach my $value ( qw{ 0 -1 } ) {
            $config_expected->{secret}{age} = $value;
            dies_ok { Pasteburn::Config::_validate( $config_expected ) }
                "dies if secret age is $value";

            $config_expected->{secret}{age} = $secret_age;
        }
    };
}

done_testing;
