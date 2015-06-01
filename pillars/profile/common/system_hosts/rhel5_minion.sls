
###############################################################################
#

{% set default_username = salt['config.get']('this_system_keys:default_username') %}

system_hosts:

    rhel5_minion:

        instantiated_by: vagrant_instance_configuration
        vagrant_instance_configuration:
            vagrant_provider: 'libvirt'
            # Example values for `base_images` depending on `vagrant_provider`:
            #   - 'uvsmtid/fedora-21-server-minimal' # libvirt
            #   - 'uvsmtid/centos-5.5-minimal' # libvirt
            #   - 'uvsmtid/centos-7.0-minimal' # libvirt
            #   - 'hansode/fedora-21-server-x86_64' # virtualbox
            #   - 'fedora:21' # docker
            base_image: 'uvsmtid/centos-5.5-minimal' # libvirt
            memory_size: 2024
            cpus_number: 2

        os_platform: rhel5

        hostname: rhel5-minion
        resolved_in: internal_net
        consider_online_for_remote_connections: True
        host_networks:
            internal_net:
                ip: 192.168.51.10
            secondary_internal_net:
                ip: 192.168.52.10
            external_net:
                ip: 192.168.61.10
            secondary_external_net:
                ip: 192.168.62.10

        primary_user: default_user

###############################################################################
# EOF
###############################################################################

