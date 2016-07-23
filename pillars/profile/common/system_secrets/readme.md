
This directory is a parent one for all secret data.

The example uses [Salt `gpg` renderer][1] to keep all secret pillar
data committed in Git repository in encrypted form.

Both (insecure) public and private GPG keys are provided to make
this example work - see [related description in states directory][2].

While it is not recommended, values can also be listed in
clear text if `gpg` renderer is not used (see [`main.sls`][3] file).

---

[1]: https://docs.saltstack.com/en/2015.8/ref/renderers/all/salt.renderers.gpg.html
[2]: /states/common/system_secrets
[3]: /pillars/profile/common/system_secrets/main.sls

