# Install `dos2unix` package.

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

dos2unix_package:
    pkg.installed:
        - name: dos2unix

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

include:
    - common.cygwin.package

{% endif %}
# >>>
###############################################################################


