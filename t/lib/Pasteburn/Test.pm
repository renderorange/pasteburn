package Pasteburn::Test;

use strict;
use warnings;

use File::Path ();

use parent 'Test::More';

our $VERSION = '0.001';

our $tempdir = '';

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

sub write_config {
    my %args = (
        config => undef,
        @_,
    );

    require File::Temp;

    $tempdir = File::Temp->newdir(
        DIR     => $FindBin::RealBin,
        CLEANUP => 0,
    );

    my $path = "$tempdir/.config/pasteburn";
    File::Path::make_path($path);
    my $rc = "$path/config.ini";

    require Config::Tiny;

    my $config_tiny = Config::Tiny->new;
    %{$config_tiny} = %{$args{config}};

    die( "unable to write config\n" )
        unless $config_tiny->write( $rc );

    return $rc;
}

END {
    if ( $tempdir ) {
        Test::More::note( "cleaning up tempdir - $tempdir" );
        unless ( File::Path::rmtree($tempdir) ) {
            Test::More::diag( "rmtree: $!\n" );
        }
    }
}

1;
