# INSTALLATION

These instructions walk through a basic installation of the Pasteburn application on Linux and will need:

- a modern version of Perl
- [sqlite3](https://sqlite.org/index.html)
- git

## CLONE THE REPO

    cd /opt/
    git clone https://github.com/renderorange/pasteburn.git
    cd pasteburn

## INSTALL THE PERL DEPENDENCIES

The Perl dependencies for this project are listed in the `cpanfile` within the repo.

## CREATE THE DATABASE

    sqlite3 db/pasteburn.sqlite3
    sqlite> .databases
    sqlite> .q
    sqlite3 db/pasteburn.sqlite3 < db/schema/schema.sqlite

## CONFIGURATION

An example configuration file, `config.ini.example`, is provided in the project root directory.

To set up the configuration file, copy the example into one of the following locations:

- `$ENV{HOME}/.config/pasteburn/config.ini`
- `/etc/pasteburn/config.ini`

After creating the file, edit and update the values accordingly.

**NOTE:** If the `$ENV{HOME}/.config/pasteburn/` directory exists, `config.ini` will be loaded from there regardless of a config file in `/etc/pasteburn/`.

### REQUIRED KEYS

- cookie

    The `cookie` section key is required, and `secret_key` option key within it.

        [cookie]
        secret_key = default

- footer

    The `footer` section key is required, and `links` option key within it.

        [footer]
        links = 1

## RUN THE DEVELOPMENT SERVER TO TEST

    app/development
    HTTP::Server::PSGI: Accepting connections at http://0:5000/
    ^C

## EXAMPLE SYSTEMD AND APACHE2 CONFIGURATION

The `app/pasteburn.service.example` file within the repo contains an example `systemd` configuration file.

Create the log file directories on the system, edit the paths and identifiers within the example file, then install and enable through systemd.

The `app/apache.conf.example` file also contains example `ProxyPass` settings for running through Apache2.
