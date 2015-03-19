# Custom tmux configuration


###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

tmux:
    pkg.installed:
        - name: tmux
        - aggregate: True

/etc/tmux.conf:
  file.managed:
    - source: salt://common/tmux/tmux.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
        - pkg: tmux


{% endif %}
# >>>
###############################################################################

