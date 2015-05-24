
###############################################################################
#

{% set default_username = salt['config.get']('this_system_keys:default_username') %}

system_hosts:

    rhel7_minion:
        instantiated_by: vagrant_instance_configuration
        vagrant_instance_configuration:
            vagrant_provider: 'libvirt'
            # Example values for `base_images` depending on `vagrant_provider`:
            #   - 'uvsmtid/fedora-21-server-minimal' # libvirt
            #   - 'uvsmtid/centos-5.5-minimal' # libvirt
            #   - 'uvsmtid/centos-7.0-minimal' # libvirt
            #   - 'hansode/fedora-21-server-x86_64' # virtualbox
            #   - 'fedora:21' # docker
            base_image: 'uvsmtid/centos-7.0-minimal' # libvirt
            network_type: 'private_network'
            host_bridge_interface: em1
            memory_size: 2024
            cpus_number: 2
        consider_online_for_remote_connections: True
        os_type: linux
        os_platform: rhel7
        hostname: rhel7-minion
        resolved_in: internal_net
        internal_net:
            ip: 192.168.50.20
        external_net:
            # This value is unused if `defined_in` is `internal_net`.
            ip: 0.0.0.0
        primary_user:
            username: {{ default_username }}
            password: {{ default_username }}
            password_hash: '$6$PGhxcpKv$wKXH3uR4BZS.1iuAR9/RB0lkcNeTJ7ag97IvIeE.QCSrRwUMLJgmlcTYbuMVnNoLXzK7MRmy2hNQrs.lD.KLS0'
            enforce_password: True

            primary_group: {{ default_username }}

            posix_user_home_dir: '/home/{{ default_username }}'
            posix_user_home_dir_windows: ~ # N/A

            windows_user_home_dir: ~ # N/A
            windows_user_home_dir_cygwin: ~ # N/A

###############################################################################
# EOF
###############################################################################

