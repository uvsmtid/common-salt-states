

###############################################################################
# <<<

# For now support is for Fedora-based system only.
{% if grains['os_platform_type'].startswith('fc') %}

install_rabbitmq_server:
    pkg.installed:
        - name: rabbitmq-server

start_rabbitmq_server:
    service.running:
        - name: rabbitmq-server
        - enable: True
        - require:
            - pkg: install_rabbitmq_server

{% endif %}

# >>>
###############################################################################


