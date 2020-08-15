use strict;
use warnings;

use Test::More;

my @required_modules = qw{
    Config::Tiny
    Crypt::PBKDF2
    Cwd
    DBD::SQLite
    DBI
    Dancer2
    Dancer2::Session::Cookie
    Data::Structure::Util
    Digest::SHA
    HTTP::Status
    Moo
    MooX::ClassAttribute
    Plack::Middleware::TrailingSlashKiller
    Scalar::Util
    Session::Storage::Secure
    Template::Toolkit
    Time::Piece
    Try::Tiny
    Types::Common::Numeric
    Types::Common::String
    namespace::clean
    strictures
};

foreach ( @required_modules ) {
    use_ok($_) or BAIL_OUT("required module $_ cannot be loaded");
};

done_testing;