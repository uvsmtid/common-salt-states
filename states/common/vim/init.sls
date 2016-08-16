# Custom vim configuration.

include:
{% if grains['os_platform_type'].startswith('win') %}
    - common.cygwin.package
{% endif %}
    - common.dummy

###############################################################################
# <<< Any RedHat-originated OS
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

{% if 'allow_package_installation_through_yum' in pillar['system_features'] and pillar['system_features']['allow_package_installation_through_yum']['feature_enabled'] %}

vim_enhanced:
    pkg.installed:
        - name: vim-enhanced
        - aggregate: True

{% endif %}

/etc/vimrc:
    file.managed:
        - source: salt://common/vim/vimrc
        - template: jinja
        - user: root
        - group: root
        - mode: 644
        - template: jinja
{% if 'allow_package_installation_through_yum' in pillar['system_features'] and pillar['system_features']['allow_package_installation_through_yum']['feature_enabled'] %}
        - require:
            - pkg: vim_enhanced
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

{% set cygwin_root_dir = cygwin_settings['installation_directory'] %}

'{{ cygwin_root_dir }}\etc\vimrc':
    file.managed:
        - source: salt://common/vim/vimrc
        - template: jinja
        - require:
            - sls: common.cygwin.package

{{ cygwin_root_dir }}\etc\vimrc_dos2unix:
    cmd.run:
        # The `--force` option is requred because `dos2unix` identifies some
        # characters as binary and skips conversion of the file.
        - name: '{{ cygwin_root_dir }}\bin\dos2unix.exe --force {{ cygwin_root_dir }}\etc\vimrc'
        - require:
            - file: '{{ cygwin_root_dir }}\etc\vimrc'

{% endif %}

{% endif %}
# >>>
###############################################################################

