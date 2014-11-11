# Custom shell prompt.

include:
    - common.shell

###############################################################################
# <<< Any RedHat-originated OS
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

/etc/profile.d/neldev.custom.prompt.sh:
    file.managed:
        - source: salt://common/shell/prompt/neldev.custom.prompt.sh
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
