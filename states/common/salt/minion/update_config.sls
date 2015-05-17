# Salt (online) minion configuration file.

###############################################################################
# <<< Any RedHat-originated OS
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

/etc/salt/minion:
    file.managed:
        - source: salt://common/salt/minion/minion.online.conf
        - template: jinja
        - context:
            selected_host_name: {{ grains['id'] }}
        - user: root
        - group: root
        - mode: 644

{% endif %}
# >>>
###############################################################################

