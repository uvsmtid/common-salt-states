###############################################################################
#

system_features:

    # Jenkins configuration
    configure_jenkins:

        feature_enabled: True

        jenkins_root_dir: '/var/lib/jenkins'

        rewrite_jenkins_configuration_for_nodes: True
        rewrite_jenkins_configuration_for_jobs: True

        # TODO: Jenkins does not support credentials management via CLI yet.
        #       Find a way to preconfigure keys to connect to the nodes.
        #       There is an issue that credentials are identified by their
        #       UUID. And because there could be various destination
        #       usernames per host, there is a need to be flexible and
        #       support multiple username credentials (even if key is
        #       the same).
        # At the moment, simply disable connecting to the nodes as it should
        # be done manually:
        #   - Go to "Credentials" configuration, select:
        #       - "SSH Username with private key"
        #       - username: username
        #       - Private Key: "From the Jenkins master ~/.ssh"
        #   - Go to each slave node configuration, select:
        #       - Launch method: "Launch slave agents on Unix machines via SSH"
        #       - Host: nelskg1a
        #       - Credentials: username
        #   - Reconnect slave node.
        #
        make_sure_nodes_are_connected: False

        # Job names should be according to the list in the following
        # directory:
        #   <BRANCH_PATH>/test/control/conf/jobs/
        # The job configuration all eventually refers to configuration there.
        #
        # TODO: Add the following note to docs.
        # NOTE: When Git is used with absolute path to repository, all
        #       checkouts reuse this repo (only symlinks are created).
        #       When Jenkins is used with Git sources, it may not be desirable
        #       because different jobs will clean each other's compilation
        #       results. In order to solve this problem, `override_git_repo_local_paths`
        #       may be used. By default, there is only single Git repository
        #       (pointed by `git_repo_local_paths` from `deploy_environment_sources`)
        #       per host. If Jenkins jobs overrides it, there will be as many
        #       Git repositories as there are unique absolute paths in total.
        #
        #       So, if defined, `override_git_repo_local_paths` goes to co-named
        #       `--override_git_repo_local_paths` parameter of `init.py` from
        #       CI control scripts.
        #       If not defined, `git_repo_local_paths` from `deploy_environment_sources`
        #       is used.
        #
        job_configs:

###############################################################################
# EOF
###############################################################################
