
###############################################################################
#

system_orchestrate_stages:

    stage_flag_files:

        # This is an automatic stage which makes sure all hosts which
        # should be accessible are actually accessible so that subsequent
        # stages trying to contact them do not fail.
        # See `consider_online_for_remote_connections` option in
        # `system_hosts` configuration.
        required_system_hosts_online:
            enable_auto_creation:                                       True
            enable_prerequisite_enforcement:                            True
            prerequisites:
                - salt_minions_ready
                - hosts_files_updated

###############################################################################
# EOF
###############################################################################

