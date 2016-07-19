
###############################################################################
#

system_orchestrate_stages:

    stage_flag_files:

        # All Salt minions are configured and connected to Salt master.
        salt_minions_ready:
            # WARNING: This flag is not automatically created because user
            #          review is required to double check all Salt minions
            #          are properly configured.
            #          On Windows manual VM restart is required.
            #          In order to start Salt minion, it is easier
            #          to restart VM after this stage completes installation.
            enable_auto_creation:                                       True
            enable_prerequisite_enforcement:                            True
            prerequisites:
                - orchestrate_stage_start

###############################################################################
# EOF
###############################################################################

