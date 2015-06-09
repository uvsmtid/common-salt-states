# Custom shell aliases.

include:
    - common.shell
{% if grains['os_platform_type'].startswith('win') %}
    - common.cygwin.package
{% endif %}

###############################################################################
# <<< Any RedHat-originated OS
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

/etc/profile.d/common.custom.aliases.sh:
    file.managed:
        - source: salt://common/shell/aliases/common.custom.aliases.sh
        - mode: 555
        - template: jinja
        - require:
            - sls: common.shell

{% endif %}
# >>>
###############################################################################


###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

{% set cygwin_content_config = pillar['system_resources']['cygwin_package_64_bit_windows'] %}

{% if cygwin_content_config['enable_installation'] %}

{% set cygwin_root_dir = cygwin_content_config['installation_directory'] %}

'{{ cygwin_root_dir }}\etc\profile.d\common.custom.aliases.sh':
    file.managed:
        - source: salt://common/shell/aliases/common.custom.aliases.sh
        - template: jinja
        - require:
            - sls: common.cygwin.package
            - sls: common.shell

{{ cygwin_root_dir }}\etc\profile.d\common.custom.aliases.sh_dos2unix:
    cmd.run:
        - name: '{{ cygwin_root_dir }}\bin\dos2unix.exe {{ cygwin_root_dir }}\etc\profile.d\common.custom.aliases.sh'
        - require:
            - file: '{{ cygwin_root_dir }}\etc\profile.d\common.custom.aliases.sh'

{% endif %}

{% endif %}
# >>>
###############################################################################

