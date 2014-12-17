# Custom vim configuration.

include:
{% if grains['os'] in [ 'Windows' ] %}
    - common.cygwin.package
{% endif %}
    - common.dummy

###############################################################################
# <<< Any RedHat-originated OS
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

{% if False %} # Installed manually.
vim_enhanced:
    pkg.installed:
        - name: vim-enhanced
{% endif %}

/etc/vimrc:
    file.managed:
        - source: salt://common/vim/vimrc
        - template: jinja
        - user: root
        - group: root
        - mode: 644
        - template: jinja
{% if False %} # Installed manually.
        - require:
            - pkg: vim_enhanced
{% endif %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

{% set cygwin_content_config = pillar['registered_content_items']['cygwin_package_64_bit_windows'] %}

{% if cygwin_content_config['enable_installation'] %}


{% set cygwin_root_dir = cygwin_content_config['installation_directory'] %}

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
