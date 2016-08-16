# Install shell package.

# Just another dummy thing:
'dummy states/common/shell/init.sls':
    cmd.run:
        - name: "echo dummy states/common/shell/init.sls"

###############################################################################
# <<< Any RedHat-originated OS
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

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
{% if grains['os_platform_type'].startswith('win') %}

{% set cygwin_content_config = pillar['system_resources']['cygwin_package_64_bit_windows'] %}

{% set cygwin_settings = pillar['system_features']['cygwin_settings'] %}

{% if cygwin_settings['cygwin_installation_method'] %}

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

