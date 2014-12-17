# Install shell package.

# Just another dummy thing:
'dummy states/common/shell/init.sls':
    cmd.run:
        - name: "echo dummy states/common/shell/init.sls"

###############################################################################
# <<< Any RedHat-originated OS
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

{% if False %} # Installed manually.
shell:
    pkg.installed:
        - name: bash
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

