
###############################################################################
#

{% set master_minion_id = salt['config.get']('this_system_keys:master_minion_id') %}

system_hosts:

    {{ master_minion_id }}:

        instantiated_by: ~
        vagrant_instance_configuration:
            vagrant_provider: 'libvirt'
            # Example values for `base_images` depending on `vagrant_provider`:
            #   - 'uvsmtid/fedora-21-server-minimal' # libvirt
            #   - 'uvsmtid/centos-5.5-minimal' # libvirt
            #   - 'uvsmtid/centos-7.0-minimal' # libvirt
            #   - 'hansode/fedora-21-server-x86_64' # virtualbox
            #   - 'fedora:21' # docker
            base_image: 'uvsmtid/fedora-21-server-minimal' # libvirt
            memory_size: 2024
            cpus_number: 2

        os_platform: fc21

        hostname: {{ master_minion_id }}
        resolved_in: primary_net
        consider_online_for_remote_connections: True
        host_networks:

            # Network available without virtualization.
            primary_net:
                ip: 192.168.1.1

            internal_net:
                ip: 192.168.51.1
            secondary_internal_net:
                ip: 192.168.52.1
            external_net:
                ip: 192.168.61.1
            secondary_external_net:
                ip: 192.168.62.1

        primary_user: master_minion_user

###############################################################################
# EOF
###############################################################################

