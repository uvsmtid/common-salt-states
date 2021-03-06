# Install `sudo` package.

include:
{% if grains['os_platform_type'].startswith('win') %}
    - common.cygwin.package
{% endif %}
    - common.dummy

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

{% if 'allow_package_installation_through_yum' in pillar['system_features'] and pillar['system_features']['allow_package_installation_through_yum']['feature_enabled'] %}

sudo_package:
    pkg.installed:
        - name: sudo
        - aggregate: True

{% endif %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

{% set cygwin_settings = pillar['system_features']['cygwin_settings'] %}

{% set cygwin_root_dir = cygwin_settings['installation_directory'] %}

# Fake command `sudo` for Windows/Cygwin.
'{{ cygwin_root_dir }}\bin\sudo':
    file.managed:
        - source: salt://{{ pillar['system_features']['configure_sudo_for_specified_users']['path_to_cygwin_sudo'] }}
        - require:
            - sls: common.cygwin.package

'{{ cygwin_root_dir }}\bin\sudo_dos2unix':
    cmd.run:
        - name: '{{ cygwin_root_dir }}\bin\dos2unix.exe {{ cygwin_root_dir }}\bin\sudo'
        - require:
            - file: '{{ cygwin_root_dir }}\bin\sudo'

'{{ cygwin_root_dir }}\bin\sudo_permissions':
    cmd.run:
        - name: '{{ cygwin_root_dir }}\bin\bash.exe -c "/usr/bin/chmod a+x /bin/sudo"'
        - require:
            - file: '{{ cygwin_root_dir }}\bin\sudo'

{% endif %}
# >>>
###############################################################################

