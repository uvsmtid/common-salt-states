# Salt (online) minion configuration file.

###############################################################################
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

/etc/salt/minion:
    file.managed:
        # NOTE: Update is only for minion connected to Master.
        - source: salt://common/salt/minion/minion.online.conf
        - template: jinja
        - context:
            selected_host_name: {{ grains['id'] }}
        - user: root
        - group: root
        - mode: 644

{% endif %}
###############################################################################

