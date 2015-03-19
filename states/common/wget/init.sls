# Install `wget` package.

include:
# Install `wget` for Windows through installing Cygwin.
{% if grains['os'] in [ 'Windows' ] %}
    - common.cygwin.package
{% endif %}
    - common.dummy

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

wget_package:
    pkg.installed:
        - name: wget
        - aggregate: True

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

{% endif %}
# >>>
###############################################################################


