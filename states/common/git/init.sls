# Custom Git configuration.

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

{% if False %} # Installed manually.
git:
    pkg.installed:
        - name: git
{% endif %}

/etc/gitconfig:
    file.managed:
        - source: salt://common/git/gitconfig
        - user: root
        - group: root
        - mode: 644
        - template: jinja
{% if False %} # Installed manually.
        - require:
            - pkg: git
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


