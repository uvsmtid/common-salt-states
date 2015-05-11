###############################################################################
#

system_features:

    # Set source symlinks to sources location on Salt master.
    #
    # Directory `/srv` is a symlink to a directory withing sources with
    # Salt states. At the same time, other files and directories from sources
    # also required for certain states. In order to avoid duplicating them
    # under `/srv`, symlinks can be set up to necessary locations within
    # sources. Then these files and directories can be served through Salt
    # to minions.
    #
    # The state does not force links to be set.
    # It only sets them if they don't exist.
    # If they exists, the state validates them.
    #
    # This feature is actually a requirement for Salt master.
    source_symlinks_configuration:

        feature_enabled: True

        # List of link paths and their targets.
        # NOTE: The dict keys are just mnemonic names. Only sub-keys are taken
        # for configuration action:
        #   `repo_name`
        #     Specify name of source repository under
        #     `deploy_environment_sources` => `source_repositories`.
        #   `abs_link_base_path`
        #     Specyfy absolute path of the link.
        #   `rel_target_path`
        #     Specify path relative to repository under `repo_name` and
        #     configured under
        #     `deploy_environment_sources` => `source_repositories`.
        source_symlinks:

            # The very initial links for `states` and `pillars`.

            salt_states_roots:
                # Repository name:
                repo_name: 'common-salt-states'
                # Absolute path:
                # TODO: Change it to common approach (with resources,
                #       or possibly pluggable projects) so that value
                #       `/srv/states` can be set for Salt config files
                #       generated for boostrap (not just hardcoded).
                #       See:
                #         docs/todo/comprehensive_artifacts_managment.md
                abs_link_base_path: '/srv/states'
                # Path relative to checked out sources' root:
                rel_target_path: 'states'

            salt_pillars_roots:
                repo_name: 'common-salt-pillars'
                abs_link_base_path: '/srv/pillars'
                rel_target_path: 'pillars'

            # Pillars for bootstrap environments.

            common.profile_name_bootstrap_pillars:
                repo_name: 'common-salt-pillars'
                abs_link_base_path: '/srv/pillars/bootstrap/pillars/profile_name'
                rel_target_path: 'pillars'

            # NOTE: In order to access the following paths from Salt master,
            #       Salt master should be configured to use additional path
            #       in `file_roots`, for example:
            #           file_roots:
            #               base:
            #                   - /srv/salt
            #                   - /srv/sources
            # The link to sources could have been placed under `/srv/salt`
            # which already poings to `./salt` in sources, but that would
            # create a loop which Salt cannot handle.

            common-salt-states_sources:
                repo_name: 'common-salt-states'
                abs_link_base_path: '/srv/sources/source_roots/common-salt-states'
                rel_target_path: ''

###############################################################################
# EOF
###############################################################################

