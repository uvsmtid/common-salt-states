
This is required directory. It must be in exact relative path from `pillars`
directory in every repository with overlaid pillars (for all cases):
*   `commons`
*   `defaults`
*   `overrides`

Automatic Salt configuration script (see [`configure_salt.py`][1])
assumes this directory is present when it creates symlinks to pillars
of target profiles to generate bootstrap package.

---

[1]: /scripts/configure_salt.py

