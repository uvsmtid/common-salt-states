
###############################################################################
#

system_orchestrate_stages:

    stage_flag_files:

        jenkins_slaves_connected:
            # NOTE:    The problem for the warning below might
            #          have already been resolved.
            #          The solution is to make sure Slave has its
            #          Jenkins credential configured (then reconnecting
            #          with the Slave using Jenkins CLI tool brings it online).
            # WARNING: Jenkins slaves cannot be connected fully automatically
            #          at the moment. There is no API to configure credentials
            #          in Jenkins master. And after configuring credentials,
            #          agents on each Jenkins slave should be restarted
            #          automatically.
            #
            #          Manually make sure that all Jenkins agents on slaves
            #          are connected. Also make sure that `java` (with
            #          correct version required by Jenkins) is in PATH
            #          on all minions (especially on Windows).
            enable_auto_creation:                                       True
            enable_prerequisite_enforcement:                            True
            prerequisites:
                - required_system_hosts_online
                - jenkins_master_installed
                - ssh_service_ready
                - ssh_keys_distributed

###############################################################################
# EOF
###############################################################################

