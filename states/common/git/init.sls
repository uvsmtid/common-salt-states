# Custom Git configuration.

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

git:
    pkg.installed:
        - name: git

/etc/gitconfig:
    file.managed:
        - source: salt://common/git/gitconfig
        - user: root
        - group: root
        - mode: 644
        - template: jinja
        - require:
            - pkg: git

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}


{% endif %}
# >>>
###############################################################################


