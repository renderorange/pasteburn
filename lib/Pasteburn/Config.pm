package Pasteburn::Config;

use strictures version => 2;

use Config::Tiny          ();
use Data::Structure::Util ();

our $VERSION = '0.013';

sub get {
    my $config = _load();
    _validate($config);

    return $config;
}

sub _get_conf_path {
    my $name = 'pasteburn';

    my $dir;
    if ( $ENV{HOME} && -d "$ENV{HOME}/.config/$name" ) {
        $dir = "$ENV{HOME}/.config";
    }
    elsif ( -d "/etc/$name" ) {
        $dir = '/etc';
    }
    else {
        die "error: unable to find config directory\n";
    }

    return "$dir/$name/config.ini";
}

sub _load {
    my $rc = _get_conf_path();

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

    return;
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

C<Pasteburn::Config> loads the project config.

=head1 METHODS

=over

=item get

Load the config and return a C<Pasteburn::Config> object.

Required keys and values are validated during load, and exception thrown if not defined or containing the default values.

=back

=head1 CONFIGURATION

An example configuration file, C<config.ini.example>, is provided in the project root directory.

To set up the configuration file, copy the example into one of the following locations:

=over

=item C<$ENV{HOME}/.config/pasteburn/config.ini>

=item C</etc/pasteburn/config.ini>

=back

After creating the file, edit and update the values accordingly.

B<NOTE:> If the C<$ENV{HOME}/.config/pasteburn/> directory exists, C<config.ini> will be loaded from there regardless of a config file in C</etc/pasteburn/>.

=head2 REQUIRED KEYS

=over

=item cookie

The C<cookie> section key is required, and C<secret_key> option key within it.

 [cookie]
 secret_key = default

=item footer

The C<footer> section key is required, and C<links> option key within it.

 [footer]
 links = 1

=back

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=cut
