#/usr/bin/env perl

use strict;
use warnings;

use FindBin    ();
use File::Find ();
use File::Spec ();

my $dir = $FindBin::RealBin;

my ( $ret, $msg ) = read_file( $dir . '/../lib/Pasteburn.pm' );
if ( !$ret ) {
    die "[error] unable to read the current version for the project: $msg";
}

my $new_version = '';
if ( $ret =~ /VERSION\s+=\s+'(\d+\.\d+)'/ ) {
    my $current_version = "$1";
    print "[info] the current version is $current_version\n";
    print "[info] enter the new version: ";
    $new_version = <STDIN>;
    $new_version =~ s/[\n\r]//g;
}
else {
    die "[error] unable to read the current version for the project\n";
}

my @files = find_all_files();
foreach my $file (@files) {
    my ( $ret, $msg ) = read_file( $dir . '/' . $file );
    if ( !$ret ) {
        die "[error] $msg";
    }

    if ( $ret =~ /VERSION\s+=\s+'(\d+\.\d+)'/ ) {
        $ret =~ s/$1/$new_version/g;

        ( $ret, $msg ) = write_file( $dir . '/' . $file . '.tmp', $ret );
        if ( !$ret ) {
            die "[error] $msg";
        }

        $ret = rename $dir . '/' . $file . '.tmp', $dir . '/' . $file;
        if ( !$ret ) {
            die "[error] $!";
        }
    }
}

sub read_file {
    my $file_path = shift;

    if ( !$file_path ) {
        return ( 0, 'file_path is required' );
    }

    my $file_contents;
    open( my $fh, '<', $file_path )
        or return ( 0, "open $file_path: $!" );
    while ( my $line = <$fh> ) {
        $file_contents .= $line;
    }
    close($fh);

    return $file_contents;
}

sub write_file {
    my $file_path     = shift;
    my $file_contents = shift;

    if ( !$file_path ) {
        return ( 0, 'file_path is required' );
    }
    if ( !$file_contents ) {
        return ( 0, 'file_contents is required' );
    }

    open( my $fh, '>', $file_path )
        or return ( 0, "open $file_path: $!" );
    print $fh $file_contents;
    close($fh);

    return 1;
}

sub find_all_files {
    my @modules;
    File::Find::find(
        sub {
            my $file = $File::Find::name;
            return unless $file =~ /\.pm$/;

            push( @modules, File::Spec->abs2rel( $file, $dir ) );
        },
        $dir . '/../',
    );

    return @modules;
}
