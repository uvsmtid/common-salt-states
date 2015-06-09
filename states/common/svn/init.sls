# Custom Subversion configuration.

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

svn:
    pkg.installed:
        - name: subversion
        - aggregate: True

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

include:
    - common.cygwin.package

# TODO: Implement configuration on Windows.

{% endif %}
# >>>
###############################################################################


