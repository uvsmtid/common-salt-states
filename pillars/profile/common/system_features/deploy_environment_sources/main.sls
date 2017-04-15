
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set project_name = props['project_name'] %}
{% set master_minion_id = props['master_minion_id'] %}
{% set profile_name = props['profile_name'] %}

# Import `maven_repo_names`.
{% set maven_repo_names_path = profile_root.replace('.', '/') + '/common/system_maven_artifacts/maven_repo_names.yaml' %}
{% import_yaml maven_repo_names_path as maven_repo_names %}
# TODO: Use `maven_repo_names` subkey in `maven_repo_names.yaml`.

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
        control_scripts_repo_name: ~

        # Sub-directory relative to sources of repository specified
        # in `control_scripts_repo_name` to find parent directory for
        # control scripts.
        #
        # After moving control scripts into their separate
        # repository `control_scripts_repo_name`, the path degenerates into empty string.
        control_scripts_dir_path: ''

        # Name of the directory for the initially deployed control scripts.
        control_scripts_dir_basename: 'control'

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

