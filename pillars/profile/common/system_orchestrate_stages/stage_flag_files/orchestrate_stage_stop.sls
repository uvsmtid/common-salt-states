
###############################################################################
#

system_orchestrate_stages:

    stage_flag_files:

        # The very last stage which is idle by purpose.
        # If `highstate` is required, it has to be run explicitly.
        # At the moment, this file configures `orchestrate`
        # to bring up the system into initially working condition.
        orchestrate_stage_stop:
            enable_auto_creation:                                       True
            enable_prerequisite_enforcement:                            True
            # TODO: There should be no explicit prerequisites.
            #       All stages should be added automatically in the SLS.
            prerequisites:
                - orchestrate_stage_start
                - salt_minions_ready
                - hosts_files_updated
                - required_system_hosts_online
                - yum_repositories_configured
                - sudo_configured
                - ssh_service_ready
                - ssh_keys_distributed
                - jenkins_master_installed
                - jenkins_slaves_connected
                - jenkins_jobs_configured

###############################################################################
# EOF
###############################################################################

