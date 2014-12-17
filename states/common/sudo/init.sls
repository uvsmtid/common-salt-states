# Install `sudo` package.

# Just another dummy thing:
'dummy states/common/sudo/init.sls':
    cmd.run:
        - name: "echo dummy states/common/sudo/init.sls"

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

{% if False %} # Installed manually.
sudo_package:
    pkg.installed:
        - name: sudo
{% endif %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}


{% endif %}
# >>>
###############################################################################

