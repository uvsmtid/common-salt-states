# Install shell package.

# Just another dummy thing:
'dummy states/common/shell/init.sls':
    cmd.run:
        - name: "echo dummy states/common/shell/init.sls"

###############################################################################
# <<< Any RedHat-originated OS
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

{% if 'allow_package_installation_through_yum' in pillar['system_features'] and pillar['system_features']['allow_package_installation_through_yum']['feature_enabled'] %}

shell:
    pkg.installed:
        - name: bash
        - aggregate: True

{% endif %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

{% set cygwin_content_config = pillar['system_resources']['cygwin_package_64_bit_windows'] %}

{% if cygwin_content_config['enable_installation'] %}

include:
    - common.cygwin.package

shell_in_cygwin_dummy:
    cmd.run:
        - name: 'echo shell_in_cygwin_dummy'
        - require:
            - sls: common.cygwin.package

{% endif %}

{% endif %}
# >>>
###############################################################################

