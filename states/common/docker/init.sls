# Virtualization using Docker container.

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel7') or grains['os_platform_type'].startswith('fc') %}

# To avoid unnecessary installation,
# require this host to be assigned to `virtual_machine_hypervisor_role`.
{% if grains['id'] in pillar['system_host_roles']['virtual_machine_hypervisor_role']['assigned_hosts'] %}

install_docker_packages:
    pkg.installed:
        - pkgs:
            - docker-io
        - aggregate: True

{% endif %} # virtual_machine_hypervisor_role

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

# TODO

{% endif %}
# >>>
###############################################################################


