package Pasteburn::Config;

use strictures version => 2;

use Cwd                   ();
use Config::Tiny          ();
use Data::Structure::Util ();

our $VERSION = '0.001';

sub get {
    my $config = _load_config();
    _validate($config);

    return $config;
}

sub _load_config {
    my $module_path = Cwd::realpath(__FILE__);
    $module_path =~ s/\w+\.pm//;
    my $rc = Cwd::realpath( $module_path . '/../../.pasteburnrc' );

    unless ( -f $rc ) {
        die "$rc is not present";
    }

    return Data::Structure::Util::unbless( Config::Tiny->read($rc) );
}

sub _validate {
    my $config = shift;

    # verify required config sections
    foreach my $required (qw{ cookie footer }) {
        unless ( exists $config->{$required} ) {
            die "config section $required is required\n";
        }
    }

    # verify cookie secret_key is set and isn't the default string in the example config
    unless ( exists $config->{cookie}{secret_key} && defined $config->{cookie}{secret_key} ) {
        die "config section cookie secret_key is required\n";
    }

    if ( $config->{cookie}{secret_key} eq 'default' ) {
        die "config section cookie secret_key is the default string and must be updated\n";
    }

    # verify footer links exists
    unless ( exists $config->{footer}{links} ) {
        die "config section footer links is required\n";
    }

    return 1;
}

1;

__END__

=pod

=head1 NAME

Pasteburn::Config - load and return the project config

=head1 SYNOPSIS

 use Pasteburn::Config;
 my $config = Pasteburn::Config->get();

=head1 DESCRIPTION

C<Pasteburn::Config> loads the project config from the project dir location and returns
it to the caller.

=head1 METHODS

=over

=item get

Load the config and return a C<Pasteburn::Config> object.

Required keys and values are validated during load, and exception thrown if not defined or containing the default values.

=back

=head1 CONFIGURATION

C<Pasteburn::Config> takes configuration options from the C<.pasteburnrc>
file within the project directory.

The C<cookie> and C<footer> keys are required.

 [cookie]
 secret_key = default
 [footer]
 links = 1

An example config is provided as a starting point.

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=cut
