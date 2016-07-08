
###############################################################################
#

system_features:

    # Time configuration: NTP, timezone, etc.
    time_configuration:
        # On Linux, this is append to the tail of this path:
        #   /usr/share/zoneinfo/
        # In other words, whatever is specified here should exists under
        # the `zoneinfo` directory above.
        timezone: Asia/Singapore

        # If enabled (`True`), all hosts will be configured to use NTP
        # servers assigned to `time_server_role` role.
        # Otherwise, default configured servers (on the Internet) will be used.
        use_time_server_role: False

        # If `time_server_role` is managed host (minion),
        # it may itself be synchronized with a list of time servers.
        # These are not time servers every other hosts is synchronized.
        # Every other hosts is synchronized with `time_server_role` which,
        # in turn, is synchronized with these time servers.
        # In other words, every other hosts use `time_server_role`
        # as stratum {N} and `time_server_role` itself uses stratum {N-1}.
        # NOTE: Every other hosts may simply be denied from accessing
        #       `time_server_role_parent_stratum_servers`.
        time_server_role_parent_stratum_servers:
            - 0.fedora.pool.ntp.org
            - 1.fedora.pool.ntp.org
            - 2.fedora.pool.ntp.org
            - 3.fedora.pool.ntp.org

###############################################################################
# EOF
###############################################################################

