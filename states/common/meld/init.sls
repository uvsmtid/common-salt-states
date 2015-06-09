# Install visual diff-tool "meld".

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

# NOTE: On RHEL5 `meld` can only be installed with EPEL repository
#       or pre-downloaded offline YUM (if configured).
install_meld_package:
    pkg.installed:
        - name: meld
        - aggregate: True

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

# Nothing to do on Windows.
# TortoiseSVN provides visual diff and merge tool.

{% endif %}
# >>>
###############################################################################


