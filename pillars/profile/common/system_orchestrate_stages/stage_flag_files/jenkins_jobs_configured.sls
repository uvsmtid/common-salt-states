
###############################################################################
#

system_orchestrate_stages:

    stage_flag_files:

        jenkins_jobs_configured:
            enable_auto_creation:                                       True
            enable_prerequisite_enforcement:                            True
            prerequisites:
                - jenkins_master_installed
                - jenkins_slaves_connected

###############################################################################
# EOF
###############################################################################

