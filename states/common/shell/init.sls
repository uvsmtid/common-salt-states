# Install shell package.

# Just another dummy thing:
'dummy states/common/shell/init.sls':
    cmd.run:
        - name: "echo dummy states/common/shell/init.sls"

###############################################################################
# <<< Any RedHat-originated OS
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

{% if 'disable_package_installation' in pillar['system_features'] and pillar['system_features']['disable_package_installation']['feature_enabled'] %}

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

{% set cygwin_content_config = pillar['registered_content_items']['cygwin_package_64_bit_windows'] %}

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

