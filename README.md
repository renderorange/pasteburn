# NAME

Pasteburn - Sharable, encrypted, ephemeral pastebin.

# DESCRIPTION

Pasteburn is a web application for encrypting and sharing secret content.

Using a secret passphrase you provide, Pasteburn encrypts your message then provides a unique link for you to share. Whomever you share the link and passphrase with can then decrypt and read your message.

Secrets can't be read without the passphrase and can't be restored once they're read or deleted.

Secrets can only be decrypted one time and are deleted when decrypted. Secrets are automatically deleted if not viewed within 7 days.

Pasteburn is built using the [Dancer2 web framework](https://metacpan.org/pod/Dancer2), [Skeleton CSS boilerplate](https://github.com/dhg/Skeleton), and [clipboard.js JS library](https://clipboardjs.com).

# CONFIGURATION

An example configuration file, `config.ini.example`, is provided in the project root directory.

To set up the configuration file, copy the example into one of the following locations:

- `$ENV{HOME}/.config/pasteburn/config.ini`
- `/etc/pasteburn/config.ini`

After creating the file, edit and update the values accordingly.

**NOTE:** If the `$ENV{HOME}/.config/pasteburn/` directory exists, `config.ini` will be loaded from there regardless of a config file in `/etc/pasteburn/`.

## REQUIRED KEYS

- cookie

    The `cookie` section key is required, and `secret_key` option key within it.

        [cookie]
        secret_key = default

- footer

    The `footer` section key is required, and `links` option key within it.

        [footer]
        links = 1

# COPYRIGHT AND LICENSE

Pasteburn is Copyright (c) 2022 Blaine Motsinger under the MIT license.

Skeleton CSS is Copyright (c) 2011-2014 Dave Gamache under the MIT license.

clipboard.js is Copyright (c) Zeno Rocha under the MIT license.

# AUTHOR

Blaine Motsinger `blaine@renderorange.com`
