###############################################################################
#

system_hosts:

    example_host:
        instantiated_by: ~
        consider_online_for_remote_connections: True
        os_type: linux
        os_platform: f21
        hostname: example_host
        defined_in: internal_net
        internal_net:
            ip: 192.168.50.1
        external_net:
            # This value is unused if `defined_in` is `internal_net`.
            ip: 0.0.0.0
        primary_user:
            username: uvsmtid
            password: uvsmtid
            password_hash: ~
            enforce_password: False

            primary_group: uvsmtid

            posix_user_home_dir: '/home/uvsmtid'
            posix_user_home_dir_windows: ~ # N/A

            windows_user_home_dir: ~ # N/A
            windows_user_home_dir_cygwin: ~ # N/A

