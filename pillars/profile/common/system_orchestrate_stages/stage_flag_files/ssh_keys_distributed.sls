
###############################################################################
#

system_orchestrate_stages:

    stage_flag_files:

        ssh_keys_distributed:
            enable_auto_creation:                                       True
            enable_prerequisite_enforcement:                            True
            prerequisites:
                - required_system_hosts_online
                - salt_minions_ready
                - ssh_service_ready

###############################################################################
# EOF
###############################################################################

