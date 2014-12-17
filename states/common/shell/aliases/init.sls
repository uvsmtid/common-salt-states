# Custom shell aliases.

include:
    - common.shell

###############################################################################
# <<< Any RedHat-originated OS
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

/etc/profile.d/common.custom.aliases.sh:
    file.managed:
        - source: salt://common/shell/aliases/common.custom.aliases.sh
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


{% endif %}
# >>>
###############################################################################

