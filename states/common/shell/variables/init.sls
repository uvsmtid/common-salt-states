# Configure custom values for shell environment variables.

###############################################################################
# <<< Any RedHat-originated OS
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

include:
    - common.shell

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

'{{ cygwin_root_dir }}\etc\profile.d\neldev.custom.variables.sh':
    file.managed:
        - template: jinja
        - require:

{{ cygwin_root_dir }}\etc\profile.d\neldev.custom.variables.sh_dos2unix:
    cmd.run:
        - name: '{{ cygwin_root_dir }}\bin\dos2unix.exe {{ cygwin_root_dir }}\etc\profile.d\neldev.custom.variables.sh'
        - require:

'{{ cygwin_root_dir }}\etc\profile.d\import_environment_to_cygwin.sh':
    file.managed:
        - template: jinja
        - require:

{{ cygwin_root_dir }}\etc\profile.d\import_environment_to_cygwin.sh_dos2unix:
    cmd.run:
        - name: '{{ cygwin_root_dir }}\bin\dos2unix.exe {{ cygwin_root_dir }}\etc\profile.d\import_environment_to_cygwin.sh'
        - require:
            - file: '{{ cygwin_root_dir }}\etc\profile.d\import_environment_to_cygwin.sh'

{% endif %}

{% endif %}
# >>>
###############################################################################

