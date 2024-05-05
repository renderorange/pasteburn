# NAME

Pasteburn - Sharable, encrypted, ephemeral pastebin.

# DESCRIPTION

Pasteburn is a web application for encrypting and sharing secret content.

Using a secret passphrase you provide, Pasteburn encrypts your message then provides a unique link for you to share. Whomever you share the link and passphrase with can then decrypt and read your message.

Secrets can't be read without the passphrase and can't be restored once they're read or deleted.

Secrets can only be decrypted one time and are deleted when decrypted. Secrets are automatically deleted if not viewed within 7 days.

Pasteburn is built using the [Dancer2 web framework](https://metacpan.org/pod/Dancer2), [Skeleton CSS boilerplate](https://github.com/dhg/Skeleton), [clipboard.js JS library](https://clipboardjs.com), and [normalize.css CSS library](https://github.com/necolas/normalize.css).

# INSTALLATION

See the [INSTALLATION.md](INSTALLATION.md) file within this repo for instructions.

# COPYRIGHT AND LICENSE

Pasteburn is Copyright (c) 2022 Blaine Motsinger under the MIT license.

Skeleton CSS is Copyright (c) 2011-2014 Dave Gamache under the MIT license.

clipboard.js is Copyright (c) Zeno Rocha under the MIT license.

normalize.css is Copyright (c) Nicolas Gallagher and Jonathan Neal under the MIT license.

# AUTHOR

Blaine Motsinger `blaine@renderorange.com`
