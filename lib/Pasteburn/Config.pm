package Pasteburn::Config;

use strictures version => 2;

use Cwd                   ();
use Config::Tiny          ();
use Data::Structure::Util ();
use List::MoreUtils       ();

our $VERSION = '0.001';

sub get {
    my $class = shift;
    my $self  = {};

    bless $self, $class;

    %{$self} = %{ $self->load_config };
    return $self;
}

sub load_config {
    my $self = shift;

    my $module_path = Cwd::realpath(__FILE__);
    $module_path =~ s/\w+\.pm//;
    my $rc = Cwd::realpath( $module_path . '/../../.pasteburnrc' );

    unless ( -f $rc ) {
        die "$rc is not present";
    }

    my $config = Config::Tiny->read($rc);
    $self->_validate($config);

    return Data::Structure::Util::unbless($config);
}

sub _validate {
    my $self   = shift;
    my $config = shift;

    # verify required config sections
    foreach my $required (qw{ cookie database }) {
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

    # verify database type
    unless ( exists $config->{database}{type} && defined $config->{database}{type} ) {
        die "config section database type is required\n";
    }

    unless ( List::MoreUtils::any { $config->{database}{type} eq $_ } (qw{ sqlite mysql }) ) {
        die "config section database type " . $config->{database}{type} . " is unknown\n";
    }

    if ( $config->{database}{type} eq 'mysql' ) {
        foreach my $required (qw{ hostname port dbname username password }) {
            unless ( exists $config->{database}{$required} ) {
                die "config section database $required is required\n";
            }
        }
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

=item load_config

Read the config from disk, verify, then return it's content.

=back

=head1 CONFIGURATION

C<Pasteburn::Config> takes configuration options from the C<.pasteburnrc>
file within the project directory.

The C<cookie> and C<database> keys are required.

 [cookie]
 secret_key = default

 [database]
 type = mysql
 hostname = 127.0.0.1
 port = 3306
 dbname = pasteburn
 username = pasteburn
 password = password

An example config is provided as a starting point.

=head1 AUTHOR

Blaine Motsinger C<blaine@renderorange.com>

=cut
