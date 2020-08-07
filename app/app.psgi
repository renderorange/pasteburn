use Plack::Builder;
use Pasteburn;

builder {
    # mount the app
    mount '/' => Pasteburn->to_app,

    # middleware
    enable 'TrailingSlashKiller',
};

__END__
