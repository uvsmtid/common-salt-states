
###############################################################################
#

system_orchestrate_stages:

    stage_flag_files:

        # All hosts files are updated to list all required system hosts.
        # NOTE: The hosts file is not updated if `hostname_resolution_type`
        #       is not set to `static_hosts_file` to avoid stale entries
        #       in case of other host resolution method is used (e.g. DNS).
        hosts_files_updated:
            enable_auto_creation:                                       True
            enable_prerequisite_enforcement:                            True
            prerequisites:
                - salt_minions_ready

###############################################################################
# EOF
###############################################################################

