
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set primary_network = props['primary_network'] %}

{% if 'winserv2012_minion' in props['enabled_minion_hosts'].keys() %}

system_hosts:

    winserv2012_minion:

        instantiated_by: vagrant_instance_configuration
        vagrant_instance_configuration:
            vagrant_provider: 'libvirt'
            base_image: 'uvsmtid/windows-server-2012-R2-gui'
            domain_config:
                memory: 2048
                cpus: 2
                #{# Use defaults with v2.0.0 of `windows-server-2012-R2-gui`.
                video_type: qxl
                disk_bus: ide
                nic_model_type: rtl8139
                #}#
            vagrant_communicator:
                communicator_type: winrm
                #{# Use defaults with v2.0.0 of `windows-server-2012-R2-gui`.
                password_secret_id: windows_server_2012_R2_gui_1_0_0_box_administrator_password
                username: 'Administrator'
                #}#

        os_platform: winserv2012

        hostname: winserv2012-minion
        resolved_in: {{ primary_network['network_name'] }}

        # NOTE:
        # - Windows/Cygwin SSH does not work with pubkey auth -
        #   there are some permissions issues for service to record pub keys.
        # - Currnent Windows Server 2012 R2 VM somehow switches off
        #   after arbitrary time - no obvious power settings to disable that.
        consider_online_for_remote_connections: False

        host_networks:

            {{ primary_network['network_name'] }}:
                ip: {{ props['enabled_minion_hosts']['winserv2012_minion'] }}
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

