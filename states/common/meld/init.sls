# Install visual diff-tool "meld".

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

# NOTE: On RHEL5 `meld` can only be installed with EPEL repository
#       or pre-downloaded offline YUM (if configured).
install_meld_package:
    pkg.installed:
        - name: meld

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

# Nothing to do on Windows.
# TortoiseSVN provides visual diff and merge tool.

{% endif %}
# >>>
###############################################################################


