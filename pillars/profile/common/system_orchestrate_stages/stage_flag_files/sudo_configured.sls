
###############################################################################
#

system_orchestrate_stages:

    stage_flag_files:

        sudo_configured:
            enable_auto_creation:                                       True
            enable_prerequisite_enforcement:                            True
            prerequisites:
                - salt_minions_ready
                - yum_repositories_configured

###############################################################################
# EOF
###############################################################################

