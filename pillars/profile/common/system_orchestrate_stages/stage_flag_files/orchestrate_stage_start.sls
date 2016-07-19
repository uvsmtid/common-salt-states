
###############################################################################
#

system_orchestrate_stages:

    stage_flag_files:

        # The very first stage without any prerequisites.
        orchestrate_stage_start:
            # WARNING: This flag should manually be created just to direct
            #          attention on the directory with stage flag files.
            enable_auto_creation:                                       True
            enable_prerequisite_enforcement:                            True
            prerequisites:
                []

###############################################################################
# EOF
###############################################################################

