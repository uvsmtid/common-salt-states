# Custom Git configuration.

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

{% if 'allow_package_installation_through_yum' in pillar['system_features'] and pillar['system_features']['allow_package_installation_through_yum']['feature_enabled'] %}

{% if grains['os_platform_type'].startswith('rhel5') %}
# Git packages are in EPEL on RHEL5.
include:
    - common.yum.epel
{% endif %}

git:
    pkg.installed:
        - name: git
{% if grains['os_platform_type'].startswith('rhel5') %}
        # Do not aggregate for packages from external repo.
        - aggregate: False
        # Git packages are in EPEL on RHEL5.
        - require:
            - sls: common.yum.epel
{% else %}
        - aggregate: True
{% endif %}

{% endif %}

/etc/gitconfig:
    file.managed:
        - source: salt://common/git/gitconfig
        - user: root
        - group: root
        - mode: 644
        - template: jinja
{% if 'allow_package_installation_through_yum' in pillar['system_features'] and pillar['system_features']['allow_package_installation_through_yum']['feature_enabled'] %}
        - require:
            - pkg: git
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

{% set cygwin_root_dir = cygwin_settings['installation_directory'] %}

'{{ cygwin_root_dir }}\etc\gitconfig':
    file.managed:
        - source: salt://common/git/gitconfig
        - template: jinja
        - require:
            - sls: common.cygwin.package

convert_git_config_to_unix_line_endings:
    cmd.run:
        - name: '{{ cygwin_root_dir }}\bin\dos2unix.exe {{ cygwin_root_dir }}\etc\gitconfig'
        - require:
            - file: '{{ cygwin_root_dir }}\etc\gitconfig'

{% endif %}

{% endif %}
# >>>
###############################################################################


