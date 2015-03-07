# Hostname configuration.

###############################################################################
# <<<
{% if grains['os'] in [ 'Fedora' ] %}

/etc/hostname:
    file.managed:
        - source: salt://common/hostname/hostname
        - user: root
        - group: root
        - mode: 644
        - template: jinja
        - context:
            - hostname: '{{ pillar['system_hosts'][grains['id']]['hostname'] }}'

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS' ] %}

/etc/sysconfig/network:
    file.replace:
        - pattern: "^\\s*HOSTNAME=.*$"
        - repl: "HOSTNAME={{ pillar['system_hosts'][grains['id']]['hostname'] }}"

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

    # TODO: Write state which changes hostname in Windows.

{% endif %}
# >>>
###############################################################################

