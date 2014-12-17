# Configure custom values for shell environment variables.

include:
    - common.shell
{% if grains['os'] in [ 'Windows' ] %}
    - common.cygwin.package
{% endif %}

###############################################################################
# <<< Any RedHat-originated OS
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

/etc/profile.d/common.custom.variables.sh:
    file.managed:
        - source: salt://common/shell/variables/common.custom.variables.sh
        - mode: 555
        - template: jinja
        - require:
            - sls: common.shell

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

{% set cygwin_content_config = pillar['registered_content_items']['cygwin_package_64_bit_windows'] %}

{% if cygwin_content_config['enable_installation'] %}

{% set cygwin_root_dir = cygwin_content_config['installation_directory'] %}

include:

'{{ cygwin_root_dir }}\etc\profile.d\common.custom.variables.sh':
    file.managed:
        - source: salt://common/shell/variables/common.custom.variables.sh
        - template: jinja
        - require:
            - sls: common.cygwin.package
            - sls: common.shell

{{ cygwin_root_dir }}\etc\profile.d\common.custom.variables.sh_dos2unix:
    cmd.run:
        - name: '{{ cygwin_root_dir }}\bin\dos2unix.exe {{ cygwin_root_dir }}\etc\profile.d\common.custom.variables.sh'
        - require:
            - sls: common.cygwin.package
            - sls: common.shell

'{{ cygwin_root_dir }}\etc\profile.d\import_environment_to_cygwin.sh':
    file.managed:
        - source: salt://common/shell/variables/import_environment_to_cygwin.sh
        - template: jinja
        - require:
            - sls: common.cygwin.package
            - sls: common.shell

{{ cygwin_root_dir }}\etc\profile.d\import_environment_to_cygwin.sh_dos2unix:
    cmd.run:
        - name: '{{ cygwin_root_dir }}\bin\dos2unix.exe {{ cygwin_root_dir }}\etc\profile.d\import_environment_to_cygwin.sh'
        - require:
            - file: '{{ cygwin_root_dir }}\etc\profile.d\import_environment_to_cygwin.sh'

{% endif %}

{% endif %}
# >>>
###############################################################################

