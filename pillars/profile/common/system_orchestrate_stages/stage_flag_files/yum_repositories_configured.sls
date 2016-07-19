
###############################################################################
#

system_orchestrate_stages:

    stage_flag_files:

        # Configure YUM repositories (e.g. including cases when local
        # YUM mirros are used) so that any installation
        # of packages can succeed.
        yum_repositories_configured:
            enable_auto_creation:                                       True
            enable_prerequisite_enforcement:                            True
            prerequisites:
                - hosts_files_updated
                - required_system_hosts_online

###############################################################################
# EOF
###############################################################################

