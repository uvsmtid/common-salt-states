

###############################################################################
# <<<

# For now support is for Fedora-based system only.
{% if grains['os_platform_type'].startswith('fc') %}

install_rabbitmq_server:
    pkg.installed:
        - name: rabbitmq-server

rabbitmq_config_file:
    file.managed:
        - source: salt://common/rabbitmq/server/rabbitmq.config
        - name: /etc/rabbitmq/rabbitmq.config
        - user: rabbitmq
        - group: rabbitmq
        - mode: 644
        - require:
            - pkg: install_rabbitmq_server

start_rabbitmq_server:
    service.running:
        - name: rabbitmq-server
        - enable: True
        - watch:
            - file: rabbitmq_config_file
        - require:
            - pkg: install_rabbitmq_server

{% endif %}

# >>>
###############################################################################


