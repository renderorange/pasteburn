package Pasteburn::Test;

use strict;
use warnings;

use File::Temp;
use File::Path ();
use Try::Tiny;

use parent 'Test::More';

our $VERSION = '0.017';

our ( $tempdir, $dbh );

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

    $tempdir = File::Temp->newdir(
        DIR     => $FindBin::RealBin,
        CLEANUP => 0,
    );

    unless ( $args{skip_db} ) {
        init_db();
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

sub init_db {
    my $db_path = $tempdir . '/test.sqlite3';
    open( my $db_fh, '>', $db_path )
        or die "open $db_path: $!\n";
    close( $db_fh );

    Test::More::note( "created test db - $db_path" );

    override(
        package => 'Pasteburn::DB',
        name    => 'load',
        subref  => sub {
            return "dbi:SQLite:dbname=$db_path"
        },
    );

    require Pasteburn::DB;
    $dbh = Pasteburn::DB::connect_db();

    my $schema;
    my $module_path = Cwd::realpath(__FILE__);
    $module_path =~ s/\w+\.pm//;
    my $schema_path = $module_path . '/../../../db/schema/schema.sqlite';
    open( my $schema_fh, '<', $schema_path )
        or die "open $schema_path: $!\n";
    while ( my $row = <$schema_fh> ) {
        $schema .= $row;
    }
    close( $schema_fh );

    my $result = try {
        return $dbh->do( $schema );
    }
    catch {
        die "insert schema failed: $_\n";
    };

    return;
}

END {
    if ( $tempdir ) {
        if ( File::Path::rmtree($tempdir) ) {
            Test::More::note( "cleaned up tempdir - $tempdir" );
        }
        else {
            Test::More::diag( "rmtree: $!\n" );
        }
    }
}

1;
