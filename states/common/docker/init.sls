# Virtualization using Docker container.

###############################################################################
# <<<
{% if grains['os'] in [ 'Fedora' ] %}

# To avoid unnecessary installation,
# require this host to be assigned to `hypervisor_role`.
{% if grains['id'] in pillar['system_host_roles']['hypervisor_role']['assigned_hosts'] %}

install_docker_packages:
    pkg.installed:
        - pkgs:
            - docker-io

{% endif %} # hypervisor_role

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

# TODO

{% endif %}
# >>>
###############################################################################


