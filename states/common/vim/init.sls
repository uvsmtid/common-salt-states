# Custom vim configuration.

###############################################################################
# <<< Any RedHat-originated OS
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

vim_enhanced:
    pkg.installed:
        - name: vim-enhanced

/etc/vimrc:
    file.managed:
        - template: jinja
        - user: root
        - group: root
        - mode: 644
        - template: jinja
        - require:
            - pkg: vim_enhanced

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}


{% endif %}
# >>>
###############################################################################

