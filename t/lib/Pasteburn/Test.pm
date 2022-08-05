package Pasteburn::Test;

use strict;
use warnings;

use File::Temp;
use File::Path ();
use Try::Tiny  ();
use Cwd        ();

use parent 'Test::More';

our $VERSION = '0.020';

our ( $tempdir, $dbh );

my $module_path = Cwd::realpath(__FILE__);
$module_path =~ s/\w+\.pm//;

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
    my $schema_path = $module_path . '/../../../db/schema/schema.sqlite';
    open( my $schema_fh, '<', $schema_path )
        or die "open $schema_path: $!\n";
    while ( my $row = <$schema_fh> ) {
        $schema .= $row;
    }
    close( $schema_fh );

    my $result = Try::Tiny::try {
        return $dbh->do( $schema );
    }
    Try::Tiny::catch {
        die "insert schema failed: $_\n";
    };

    # NOTE: the initdb process doesn't appear to create the index.
    # my guess is that the do statement doesn't handle more than one statement in the query,
    # and since the schema file has both the CREATE TABLE and CREATE UNIQUE INDEX statements,
    # only the first one is executed.
    # until this is solved, just add the index within it's own statement.
    my $create_index_query = 'CREATE UNIQUE INDEX idx_secrets_id ON secrets (id)';

    $result = Try::Tiny::try {
        return $dbh->do( $create_index_query );
    }
    Try::Tiny::catch {
        die "insert index failed: $_\n";
    };

    return;
}

sub create_test_app {
    my %args = (
        config => undef,
        @_,
    );

    foreach my $required ( keys %args ) {
        unless ( defined $args{$required} ) {
            die "$required is required";
        }
    }

    unless ( ref $args{config} eq 'HASH' ) {
        die "config must be a hashref";
    }

    override(
        package => 'Pasteburn::Config',
        name    => 'get',
        subref  => sub { return $args{config} },
    );

    my $app_dir = Cwd::realpath( $module_path . '../../../app/' );
    $ENV{DANCER_CONFDIR} = $app_dir;
    $ENV{DANCER_ENVIRONMENT} = 'development';

    require Pasteburn;
    my $app = Pasteburn->to_app;

    require Plack::Test;
    return Plack::Test->create( $app );
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
