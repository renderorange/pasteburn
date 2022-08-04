use strict;
use warnings;

use FindBin;
use Test::More;

my $dir = $FindBin::RealBin;
my $cpanfile = $dir . '/../cpanfile';

my ( $ret, $msg ) = read_file( $cpanfile );
if ( !$ret ) {
    BAIL_OUT($msg);
}

my @requires_modules;
my @test_requires_modules;

foreach my $line ( split /\n/, $ret ) {
    my $module;
    if ( $line =~ /requires\s+'(.+)'/ ) {
        $module = $1;
    }
    else {
        next;
    }

    if ( $line =~ /^requires/ ) {
        push @requires_modules, $module;
    }
    elsif ( $line =~ /^test/ ) {
        push @test_requires_modules, $module;
    }
}

Test::More::note( 'requires modules' );
foreach my $module ( @requires_modules ) {
    require_ok($module) or BAIL_OUT("requires module $module cannot be loaded");
};

Test::More::note( 'test requires modules' );
foreach my $module ( @test_requires_modules ) {
    require_ok($module) or BAIL_OUT("test requires module $module cannot be loaded");
};

done_testing;

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
