# Custom Subversion configuration.

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

svn:
    pkg.installed:
        - name: subversion
        - aggregate: True

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

include:
    - common.cygwin.package

# TODO: Implement configuration on Windows.

{% endif %}
# >>>
###############################################################################


