package Pasteburn::Config;

use strictures version => 2;

use Config::Tiny          ();
use Data::Structure::Util ();

our $VERSION = '0.023';

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
    foreach my $required (qw{ secret passphrase cookie footer }) {
        unless ( exists $config->{$required} ) {
            die "config section $required is required\n";
        }
    }

    unless ( exists $config->{secret}{age} ) {
        die "config section secret age is required\n";
    }

    if ( $config->{secret}{age} < 1 ) {
        die "config section secret age must be a positive integer\n";
    }

    unless ( exists $config->{secret}{scrub} && ( $config->{secret}{scrub} == 1 || $config->{secret}{scrub} == 0 ) ) {
        die "config section secret scrub is required\n";
    }

    unless ( exists $config->{passphrase}{allow_blank}
        && ( $config->{passphrase}{allow_blank} == 1 || $config->{passphrase}{allow_blank} == 0 ) ) {
        die "config section passphrase allow_blank is required\n";
    }

    unless ( exists $config->{cookie}{secret_key} && $config->{cookie}{secret_key} ) {
        die "config section cookie secret_key is required\n";
    }

    # verify cookie secret_key isn't the default string in the example config
    if ( $config->{cookie}{secret_key} eq 'default' ) {
        die "config section cookie secret_key is the default string and must be updated\n";
    }

    unless ( exists $config->{footer}{links} && ( $config->{footer}{links} == 1 || $config->{footer}{links} == 0 ) ) {
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

An example configuration file, C<config.ini.example>, is provided in the examples directory.

To set up the configuration file, copy the example into one of the following locations:

=over

=item C<$ENV{HOME}/.config/pasteburn/config.ini>

=item C</etc/pasteburn/config.ini>

=back

After creating the file, edit and update the values accordingly.

B<NOTE:> If the C<$ENV{HOME}/.config/pasteburn/> directory exists, C<config.ini> will be loaded from there regardless of a config file in C</etc/pasteburn/>.

=head2 REQUIRED KEYS

=over

=item secret

The C<secret> section key is required, C<age> and C<scrub> option keys within it.

 [secret]
 age = 604800
 scrub = 1

To change the default time to expire secrets, change the C<age> value.  The value must be a positive integer.  The C<age> value is only enforced if running the C<delete_expired_secrets.pl> script, as noted below.

If C<scrub> is set to 1, HTML tags will be removed from the secret string before storing and again as it's retrieved from the database.  If set to 0, HTML tags will not be removed from the secret.

B<NOTE:> Setting C<scrub> to 0 means XSS vulnerabilities will be possible in the textarea box as it's displayed.  Disable this setting with caution.

=item passphrase

The C<passphrase> section key is required, and the C<allow_blank> option key within it.

 [passphrase]
 allow_blank = 0

The allow users to set a blank passphrase, change C<allow_blank> to C<1>.

=item cookie

The C<cookie> section key is required, and C<secret_key> option key within it.

 [cookie]
 secret_key = default

Set the C<secret_key> value to a complex random string for your installation.

=item footer

The C<footer> section key is required, and C<links> option key within it.

 [footer]
 links = 1

To disable the links in the footer, set the C<links> value to C<0>.

=back

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=cut
