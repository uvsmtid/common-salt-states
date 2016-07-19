
###############################################################################
#

system_orchestrate_stages:

    stage_flag_files:

        jenkins_master_installed:
            enable_auto_creation:                                       True
            enable_prerequisite_enforcement:                            True
            prerequisites:
                - ssh_keys_distributed
                - yum_repositories_configured

###############################################################################
# EOF
###############################################################################

