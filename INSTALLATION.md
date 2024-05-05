# INSTALLATION

These instructions walk through a basic installation of the Pasteburn application on Linux and will need:

- a modern version of Perl
- [sqlite3](https://sqlite.org/index.html)
- git

## CLONE THE REPO

    cd /opt/
    git clone https://github.com/renderorange/pasteburn.git
    cd pasteburn

## INSTALL THE SYSTEM DEPENDENCIES

(these instructions assume running on Debian or Ubuntu)

    apt-get install cpanminus sqlite3

## INSTALL THE PERL DEPENDENCIES

(again, Debian or Ubuntu)

The Perl dependencies for this project are listed in the `cpanfile` within the repo.

    cpanm -n Config::Tiny Crypt::Eksblowfish::Bcrypt Crypt::Random Cwd Dancer2 Dancer2::Session::Cookie Data::Structure::Util DBD::SQLite DBI Digest::SHA Encode Getopt::Long HTTP::Status Moo MooX::ClassAttribute namespace::clean Plack::Builder Plack::Middleware::TrailingSlashKiller Pod::Usage Scalar::Util Session::Storage::Secure strictures Template::Toolkit Time::Piece Try::Tiny

## CREATE THE DATABASE

    sqlite3 db/pasteburn.sqlite3
    sqlite> .databases
    sqlite> .q
    sqlite3 db/pasteburn.sqlite3 < db/schema/schema.sqlite

## CONFIGURATION

An example configuration file, `config.ini.example`, is provided in the examples directory.

To set up the configuration file, copy the example into one of the following locations:

- `$ENV{HOME}/.config/pasteburn/config.ini`
- `/etc/pasteburn/config.ini`

After creating the file, edit and update the values accordingly.

**NOTE:** If the `$ENV{HOME}/.config/pasteburn/` directory exists, `config.ini` will be loaded from there regardless of a config file in `/etc/pasteburn/`.

### REQUIRED KEYS

- secret

    The `secret` section key is required, and `age` option key within it.

        [secret]
        age = 604800

    To change the default time to expire secrets, change the `age` value.  The value must be a positive integer.  The `age` value is only enforced if running the `delete_expired_secrets.pl` script, as noted below.

- passphrase

    The `passphrase` section key is required, and the `allow_blank` option key within it.

        [passphrase]
        allow_blank = 0

    The allow users to set a blank passphrase, change `allow_blank` to `1`.

- cookie

    The `cookie` section key is required, and `secret_key` option key within it.

        [cookie]
        secret_key = default

    Set the `secret_key` value to a complex random string for your installation.

- footer

    The `footer` section key is required, and `links` option key within it.

        [footer]
        links = 1

    To disable the links in the footer, set the `links` value to `0`.

## RUN THE DEVELOPMENT SERVER TO TEST

    app/development
    HTTP::Server::PSGI: Accepting connections at http://0:5000/
    ^C

## EXAMPLE SYSTEMD AND APACHE2 CONFIGURATION

The `pasteburn.service.example` file within the examples directory contains an example `systemd` configuration file.

Create the log file directories on the system, edit the paths and identifiers within the example file, then install and enable through systemd.

Once installed, enable and start the service.

    systemctl enable pasteburn
    systemctl start pasteburn

It's recommended to run Pasteburn proxy behind a frontend webserver.  The `apache.conf.example` file within the examples directory contains example `ProxyPass` settings for running behind Apache2.

## AUTOMATICALLY DELETE EXPIRED SECRETS

To automatically delete expired secrets after the configured secret age, create a cronjob to run the `bin/delete_expired_secrets.pl` script every minute.

    * * * * * export PERL5LIB=/opt/pasteburn/lib:$PERL5LIB; cd /opt/pasteburn/ && perl bin/delete_expired_secrets.pl

To allow secrets to persist without an expiration, disable the cronjob to delete expired secrets.
