
###############################################################################
#

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
            network_type: 'private_network'
            host_bridge_interface: em1
            memory_size: 2024
            cpus_number: 2
        consider_online_for_remote_connections: True
        os_type: linux
        os_platform: rhel5
        hostname: rhel5-minion
        defined_in: internal_net
        internal_net:
            ip: 192.168.50.10
        external_net:
            # This value is unused if `defined_in` is `internal_net`.
            ip: 0.0.0.0
        primary_user:
            username: uvsmtid
            password: uvsmtid
            password_hash: '$1$kBDpSGYe$bk8YAwQshTb/LTvTTFr/4.'
            enforce_password: True

            primary_group: uvsmtid

            posix_user_home_dir: '/home/uvsmtid'
            posix_user_home_dir_windows: ~ # N/A

            windows_user_home_dir: ~ # N/A
            windows_user_home_dir_cygwin: ~ # N/A

###############################################################################
# EOF
###############################################################################
