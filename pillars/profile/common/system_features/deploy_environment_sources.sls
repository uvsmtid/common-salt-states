###############################################################################
#

{% set master_minion_id = salt['config.get']('this_system_keys:master_minion_id') %}
{% set profile_name = salt['config.get']('this_system_keys:profile_name') %}

system_features:

    # Deploy source code on all required minions.
    deploy_environment_sources:

        # The deployment is done in few phases:
        #   - Prepare a directory with source code of control scripts manually.
        #   - Use path to manually prepared control scripts to deploy them
        #     on all required minions.
        #   - Use control scripts on each minion to pull the rest of sources.

        # TODO: This is an obsolete approach with control scripts in special
        #       external repository. Disable until a better solution found.
        #       Even though environment sources are not deployed,
        #       configuration is still central for all source code repos.
        feature_enabled: False

        # Specify hosts by their hostname (not minion id) to avoid pushing
        # sources to them.
        #
        # Some hosts specified in `system_hosts` are not minions and may
        # not need pre-deployed sources (because no minion jobs can be
        # executed while host is not a minion controlled by Salt).
        exclude_hosts:
            - dummy

        # The sources are supposed to be deployed by control scripts
        # which handle multiple repositories (and types of repositories).
        # In order to deploy this control scripts, "chicken and egg" problem
        # is addressed first:
        #   - Control scripts perform checkout.
        #   - How to checkout control scripts?
        # Therefore, the control scripts themselves are deployed by other
        # means (i.e. `scp`, or Salt modules, or something else -
        # implementation may change).
        # Parameter `control_scripts_repo_name` is used to specify name
        # of repository which is later looked up under `source_repositories`
        # to find location of initial control scripts under
        # `salt_master_local_path`.
        control_scripts_repo_name: 'ci-job-control'

        # Sub-directory relative to sources of repository specified
        # in `control_scripts_repo_name` to find parent directory for
        # control scripts.
        #
        # After moving control scripts into their separate
        # repository `ci-job-control`, the path degenerates into empty string.
        control_scripts_dir_path: ''

        # Name of the directory for the initially deployed control scripts.
        control_scripts_dir_basename: 'control'

        # Specify type per repository:
        #  - `svn` for Subversion.
        #  - `git` for Git.
        source_repo_types:

            # Salt states.

            'common-salt-states': git

            # Salt pillars.

            'common-salt-pillars': git

            # Salt resources.

            'common-salt-resources': git

        # This is passed to override descriptor configuration on control
        # scripts command line. It could probably be placed directly in
        # Git configuration below (as it is in descriptor), but composing
        # this data in templates is awkward while this makes it is ready to
        # use (just like another similar override config `source_repo_types`)
        # via rendering into JSON.
        git_repo_local_paths:
            # Local path per Git repo:
            # - if absolute, it is single for all checkouts;
            # - if relative, it is single per job (control scripts).

            'common-salt-states': '/environment.sources/common-salt-states.git'

            'common-salt-pillars': '/environment.sources/common-salt-pillars.git'

            'common-salt-resources': '/environment.sources/common-salt-resources.git'

        # Central source repository configuration.
        # The following values are passed to templates for descriptor and
        # job configuration to let control scripts complete the task of
        # deploying environement sources.
        #   `salt_master_local_path*`
        #
        #     Specify path of manually checked out directory on Salt master.
        #
        #     The `*_base` part specifies path which is likely to change
        #     from one environment to another. And the `*_rest` part specifies
        #     what is likely to stay the same. This is to simplify visual
        #     comparision and highlight only the changes which matter (which
        #     are those in `*_base`).
        #
        #   `origin_url`
        #     For Git only.
        #     Specify remote URL (origin) to clone repo on all minions.
        #   `branch_name`
        #     For Git only.
        #     Specify branch name to be checked out.
        #   `root_url`
        #     For Subversion only.
        #     Specify root URL of repository.
        #   `branch_path`
        #     For Subversion only.
        #     Specify path to branch relative to repository root URL.
        source_repositories:

            'common-salt-states':
                git:
                    source_system_host: '{{ master_minion_id }}'

                    origin_uri_ssh_path: 'Works/common-salt-states.git'

                    branch_name: 'master'

            'common-salt-pillars':
                git:
                    source_system_host: '{{ master_minion_id }}'

                    origin_uri_ssh_path: 'Works/common-salt-pillars.git'

                    branch_name: 'develop'

            'common-salt-resources':
                git:
                    source_system_host: '{{ master_minion_id }}'

                    origin_uri_ssh_path: 'Works/common-salt-resources.git'

                    branch_name: 'master'

        # Environment sources location:
        # The keys are those used in `os_type` field under `system_platforms`.
        environment_sources_location:
            windows:
                path: 'C:\environment.sources'
                path_cygwin: '/cygdrive/c/environment.sources'
                # TODO: Maybe simply use path `C:\cygwin64\environment.sources`
                #       without any links to make everything the same
                #       (`/environment.sources`) from the point of view of
                #       shell in SSH session to Windows or Linux?
                #
                #       When using Git with absolute path to repository,
                #       it is more straightforward to keep the path compartible
                #       (the same) across platforms. Otherwise, control
                #       descriptor won't provide required path depending on
                #       the platform. There are few solutions:
                #       - provide the following link below (so, both
                #         Linux and Cygwin/Windows paths are compartible);
                #       - provide command line argument which will override
                #         repo path through command line depending on
                #         the platform where the job is supposed to run.
                #       Although control scripts support the second approach,
                #       it is cumbersome: paths are potentially different
                #       depending on the platform, repository type, etc. which
                #       makes it error-prone and confusing for implementation.
                #       Instead link is created.
                link_cygwin: '/environment.sources'
            linux:
                path: '/environment.sources'

###############################################################################
# EOF
###############################################################################

