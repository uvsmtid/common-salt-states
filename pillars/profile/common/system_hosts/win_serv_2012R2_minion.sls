
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set primary_network = props['primary_network'] %}

{% if 'win_serv_2012R2_minion' in props['enabled_minion_hosts'].keys() %}

system_hosts:

    win_serv_2012R2_minion:

        instantiated_by: vagrant_instance_configuration
        vagrant_instance_configuration:
            vagrant_provider: 'libvirt'
            base_image: 'uvsmtid/windows-server-2012-R2-gui'
            domain_config:
                memory: 2048
                cpus: 2
                video_type: qxl
                disk_bus: ide
                nic_model_type: rtl8139

        os_platform: winserv2012

        hostname: win-serv-2012R2-minion
        resolved_in: {{ primary_network['network_name'] }}
        consider_online_for_remote_connections: True
        host_networks:

            {{ primary_network['network_name'] }}:
                ip: {{ props['enabled_minion_hosts']['win_serv_2012R2_minion'] }}
                mac: 52:54:00:3f:ce:e6

            internal_net_A:
                ip: 192.168.51.40
            internal_net_B:
                ip: 192.168.52.40
            external_net_A:
                ip: 192.168.61.40
            external_net_B:
                ip: 192.168.62.40

        primary_user: default_user

{% endif %}

###############################################################################
# EOF
###############################################################################

