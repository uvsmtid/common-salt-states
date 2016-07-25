
See also [related pillar directory][1].

This directory contains (insecure) private and public key pair to
be used as examples together with [Salt `gpg` renderer][2].

Follow original description for `gpg` renderer to create key storage.

NOTE:
Set environment variale `GPG_KEY_NAME` to `project_name`-specific key name.
In the following document, it is assumed is set as:

```
export GPG_KEY_NAME="Alexey Pakseykin (insecure test fake public) <uvsmtid@gmail.com>"
```

NOTE:
Create `/etc/salt/gpgkeys` directory if it is not available:

```
sudo mkdir -p /etc/salt/gpgkeys
sudo chmod 0700 /etc/salt/gpgkeys
```

*   [`insecure_public_key.gpg`][pub_key]

    The key was exported using this command:

    ```
    sudo gpg \
        --homedir /etc/salt/gpgkeys \
        --armor \
        --export "${GPG_KEY_NAME}" \
        > states/common/system_secrets/insecure_public_key.gpg
    ```

    In order to generate secrets/ciphers,
    import the public key first (for current regular user):

    ```
    gpg --import states/common/system_secrets/insecure_public_key.gpg
    ```

    Then, use the following command:

    ```
    echo -n "supersecret" | gpg --armor --encrypt -r "${GPG_KEY_NAME}"
    ```

*   [`insecure_private_key.gpg`][priv_key]

    Normal private key file is secret and is not publicly available.

    A new private key can be generated using the command similar to
    the following one, however, using this new private key would
    invalidate all secrets/ciphers currently encrypted by
    the other private key:

    ```
    sudo gpg \
        --gen-key \
        --homedir /etc/salt/gpgkeys
    ```

    The private key is not supposed to be stored here.
    Instead, it is obtained for deployment and imported to
    GPG store on the Salt master only.

    Once obtained, import the private on the Salt master using this command:

    ```
    sudo gpg \
        --homedir /etc/salt/gpgkeys \
        --allow-secret-key-import \
        --import private_key.gpg
    ```

    To export the private key from existing Salt master with
    required private key deployed, run this command:

    ```
    sudo gpg \
        --homedir /etc/salt/gpgkeys \
        --armor \
        --export-secret-keys "${GPG_KEY_NAME}" \
        > private_key.gpg
    ```

## Prerequisites ##

Salt before `2015.8.3` requires installing Python GPG support.

For example, on Fedora 24:

```
sudo dnf install python2-gnupg
```

---

[1]: /pillars/profile/common/system_secrets
[2]: https://docs.saltstack.com/en/2015.8/ref/renderers/all/salt.renderers.gpg.html

[priv_key]: /states/common/system_secrets/insecure_private_key.gpg

[pub_key]: /states/common/system_secrets/insecure_public_key.gpg

