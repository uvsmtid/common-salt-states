# Custom vim configuration.

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


{% endif %}
# >>>
###############################################################################

