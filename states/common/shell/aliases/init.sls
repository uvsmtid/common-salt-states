# Custom shell aliases.

include:
    - common.shell

###############################################################################
# <<< Any RedHat-originated OS
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

/etc/profile.d/neldev.custom.aliases.sh:
  file.managed:
    - source: salt://common/shell/aliases/neldev.custom.aliases.sh
    - mode: 555
    - template: jinja
    - require:
        - pkg: shell

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}


{% endif %}
# >>>
###############################################################################

