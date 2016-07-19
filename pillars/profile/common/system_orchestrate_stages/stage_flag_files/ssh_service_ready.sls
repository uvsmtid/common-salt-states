
###############################################################################
#

system_orchestrate_stages:

    stage_flag_files:

        ssh_service_ready:
            # NOTE: This may require to be a manual step because
            #       manual VM restart is required in order to start
            #       SSH server on Cygwin.
            #       It is easier to restart VM after this
            #       stage completes installation.
            enable_auto_creation:                                       True
            enable_prerequisite_enforcement:                            True
            prerequisites:
                - salt_minions_ready
                - yum_repositories_configured

###############################################################################
# EOF
###############################################################################

