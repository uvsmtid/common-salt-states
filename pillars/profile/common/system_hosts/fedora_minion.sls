
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set primary_network = props['primary_network'] %}

{% set host_id = 'fedora_minion' %}
{% if host_id in props['enabled_minion_hosts'].keys() %}

system_hosts:

    {{ host_id }}:

        instantiated_by: vagrant_instance_configuration
        vagrant_instance_configuration:
            vagrant_provider: 'libvirt'
            # Example values for `base_images` depending on `vagrant_provider`:
            #   - 'uvsmtid/fedora-21-server-minimal' # libvirt
            #   - 'uvsmtid/centos-5.5-minimal' # libvirt
            #   - 'uvsmtid/centos-7.0-minimal' # libvirt
            #   - 'hansode/fedora-21-server-x86_64' # virtualbox
            #   - 'fedora:21' # docker
            base_image: 'fedora/24-cloud-base' # libvirt
            domain_config:
                memory: 2048
                cpus: 2
            vagrant_communicator:
                communicator_type: ssh

        os_platform: fc25

        hostname: {{ host_id|replace("_", "-") }}
        resolved_in: {{ primary_network['network_name'] }}
        consider_online_for_remote_connections: True
        host_networks:

            {{ primary_network['network_name'] }}:
                ip: {{ props['enabled_minion_hosts'][host_id] }}
                mac: 52:54:00:88:1c:4b

            internal_net_A:
                ip: 192.168.51.30
            internal_net_B:
                ip: 192.168.52.30
            external_net_A:
                ip: 192.168.61.30
            external_net_B:
                ip: 192.168.62.30

        primary_user: default_user

{% endif %}

###############################################################################
# EOF
###############################################################################

