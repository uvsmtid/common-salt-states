
###############################################################################
#

system_orchestrate_stages:

    # This path is relative to primary user's home:
    deployment_directory_path: 'salt_orchestration_stage_flag_files'

    #--------------------------------------------------------------------------
    # Stage Flag Files
    #
    # Each key in the following dict represends name of the flag file.
    #
    # - Option `enable_auto_creation` allows creating corresponding file
    #   automatically after successfully executing all orchestration states
    #   required by this stage flag file.
    #
    # - Option `enable_prerequisite_enforcement` makes this stage flag file
    #   actually depend on list of other files specified in `prerequisites`
    #   list. In other word, it enforces `prerequisites`.
    #
    stage_flag_files:

        # DONE
        # The very first stage without any prerequisites.
        orchestrate_stage_start:
            # WARNING: This flag should manually be created just to direct
            #          attention on the directory with stage flag files.
            enable_auto_creation:                                       True
            enable_prerequisite_enforcement:                            True
            prerequisites:
                []

        # DONE
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

        # DONE
        # This is an automatic stage which makes sure all hosts which
        # should be accessible are actually accessible so that subsequent
        # stages trying to contact them do not fail.
        # See `consider_online_for_remote_connections` option in
        # `system_hosts` configuration.
        required_system_hosts_online:
            enable_auto_creation:                                       True
            enable_prerequisite_enforcement:                            True
            prerequisites:
                - orchestrate_stage_start
                - salt_minions_ready

        # DONE
        sudo_configured:
            enable_auto_creation:                                       True
            enable_prerequisite_enforcement:                            True
            prerequisites:
                - salt_minions_ready

        # DONE
        ssh_service_ready:
            # NOTE: This is manual step because manual VM restart is required.
            #       In order to start SSH server on Cygwin, it is easier
            #       to restart VM after this stage completes installation.
            enable_auto_creation:                                       True
            enable_prerequisite_enforcement:                            True
            prerequisites:
                - salt_minions_ready

        # DONE
        ssh_keys_distributed:
            enable_auto_creation:                                       True
            enable_prerequisite_enforcement:                            True
            prerequisites:
                - required_system_hosts_online
                - salt_minions_ready
                - ssh_service_ready

        # DONE
        jenkins_master_installed:
            enable_auto_creation:                                       True
            enable_prerequisite_enforcement:                            True
            prerequisites:
                - ssh_keys_distributed

        # DONE
        jenkins_slaves_connected:
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

        # DONE
        jenkins_jobs_configured:
            enable_auto_creation:                                       True
            enable_prerequisite_enforcement:                            True
            prerequisites:
                - jenkins_master_installed
                - jenkins_slaves_connected

        # DONE
        # The very last stage which runs highstate on all minions.
        stop:
            enable_auto_creation:                                       True
            enable_prerequisite_enforcement:                            True
            # TODO: There should be no explicit prerequisites.
            #       All stages should be added automatically in the SLS.
            prerequisites:
                - orchestrate_stage_start
                - salt_minions_ready
                - required_system_hosts_online
                - sudo_configured
                - ssh_service_ready
                - ssh_keys_distributed
                - jenkins_master_installed
                - jenkins_slaves_connected
                - jenkins_jobs_configured

###############################################################################
# EOF
###############################################################################

