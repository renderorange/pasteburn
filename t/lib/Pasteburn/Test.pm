package Pasteburn::Test;

use strict;
use warnings;

use parent 'Test::More';

our $VERSION = '0.001';

sub import {
    my $class = shift;
    my %args  = @_;

    if ( $args{tests} ) {
        $class->builder->plan( tests => $args{tests} )
            unless $args{tests} eq 'no_declare';
    }
    elsif ( $args{skip_all} ) {
        $class->builder->plan( skip_all => $args{skip_all} );
    }

    Test::More->export_to_level(1);

    require Test::Exception;
    Test::Exception->export_to_level(1);

    require Test::Deep;
    Test::Deep->export_to_level(1);

    require Test::Warnings;

    return;
}

sub override {
    my %args = (
        package => undef,
        name    => undef,
        subref  => undef,
        @_,
    );

    eval "require $args{package}";

    my $fullname = sprintf "%s::%s", $args{package}, $args{name};

    no strict 'refs';
    no warnings 'redefine', 'prototype';
    *$fullname = $args{subref};

    return;
}

1;
