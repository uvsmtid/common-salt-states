# Custom tmux configuration


###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

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

