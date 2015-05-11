###############################################################################
#

system_features:

    # Hostname resolution configuration.
    hostname_resolution_config:

        # See: docs/pillars/common/system_features/hostname_resolution_config/hostname_resolution_type/readme.md
        hostname_resolution_type: static_hosts_file

        # Managed DNS zone for this system.
        #
        # All hosts in `internal_net` or `external_net` are resolved as part
        # of this domain zone.
        #
        # The DNS server is configured in `resolver_role` role. See `system_host_roles`.
        domain_name: project.example.com

        # TODO: It is better to use role name to select host (with IP)
        #       rather than specify raw IP address.
        # X server (where X applications can open display).
        # This name will be resolvable by DNS.
        # Normally, it should be the IP of the machine (usually physical) from which
        # developer interacts with the system.
        x_display_server: 142.1.1.1

###############################################################################
# EOF
###############################################################################
