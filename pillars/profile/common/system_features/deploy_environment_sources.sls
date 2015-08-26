
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set project_name = props['project_name'] %}
{% set master_minion_id = props['master_minion_id'] %}
{% set profile_name = props['profile_name'] %}
{% set current_task_branch = props['current_task_branch'] %}

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

        # Specify type per repository:
        #  - `svn` for Subversion.
        #  - `git` for Git.
        source_repo_types:

            # Main repository with submodules.

            {% if props['parent_repo_name'] %}
            {{ props['parent_repo_name'] }}: git
            {% endif %}

            # Salt states.

            'common-salt-states': git

            {% if project_name != 'common' %}
            '{{ project_name }}-salt-states': git
            {% endif %}

            # Salt resources.

            'common-salt-resources': git

            {% if project_name != 'common' %}
            '{{ project_name }}-salt-resources': git
            {% endif %}

            # Salt pillars.

            '{{ project_name }}-salt-pillars': git

            '{{ project_name }}-salt-pillars.bootstrap-target': git

            # Maven repositories.

            {% for maven_repo_name in maven_repo_names %}

            '{{ maven_repo_name }}': git

            {% endfor %}

            # Other repositories.

            # ...

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

            # Main repository with submodules.

            {% if props['parent_repo_name'] %}
            '{{ props['parent_repo_name'] }}': '/environment.sources/{{ props['parent_repo_name'] }}'
            {% endif %}

            # Salt states.

            'common-salt-states': '/environment.sources/common-salt-states.git'

            {% if project_name != 'common' %}
            '{{ project_name }}-salt-states': '/environment.sources/{{ project_name }}-salt-states.git'
            {% endif %}

            # Salt resources.

            'common-salt-resources': '/environment.sources/common-salt-resources.git'

            {% if project_name != 'common' %}
            '{{ project_name }}-salt-resources': '/environment.sources/{{ project_name }}-salt-resources.git'
            {% endif %}

            # Salt pillars.

            '{{ project_name }}-salt-pillars': '/environment.sources/{{ project_name }}-salt-pillars.git'

            '{{ project_name }}-salt-pillars.bootstrap-target': '/environment.sources/{{ project_name }}-salt-pillars.bootstrap-target.git'

            # Maven repositories.

            {% for maven_repo_name in maven_repo_names %}

            '{{ maven_repo_name }}': '/environment.sources/observer.git/maven/{{ maven_repo_name }}.git'

            {% endfor %}

            # Other repositories.

            # ...

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

            # Main repository with submodules.

            {% if props['parent_repo_name'] %}

            '{{ props['parent_repo_name'] }}':
                git:
                    source_system_host: '{{ master_minion_id }}'

                    origin_uri_ssh_path: 'Works/{{ props['parent_repo_name'] }}.git'

                    branch_name: 'develop'

            {% endif %}

            # Salt states.

            'common-salt-states':
                git:
                    source_system_host: '{{ master_minion_id }}'

                    origin_uri_ssh_path: 'Works/common-salt-states.git'

                    branch_name: '{{ current_task_branch }}'

            {% if project_name != 'common' %}
            '{{ project_name }}-salt-states':
                git:
                    source_system_host: '{{ master_minion_id }}'

                    origin_uri_ssh_path: 'Works/{{ project_name }}-salt-states.git'

                    branch_name: '{{ current_task_branch }}'
            {% endif %}

            # Salt resources.

            'common-salt-resources':
                git:
                    source_system_host: '{{ master_minion_id }}'

                    origin_uri_ssh_path: 'Works/common-salt-resources.git'

                    branch_name: '{{ current_task_branch }}'

            {% if project_name != 'common' %}
            '{{ project_name }}-salt-resources':
                git:
                    source_system_host: '{{ master_minion_id }}'

                    origin_uri_ssh_path: 'Works/{{ project_name }}-salt-resources.git'

                    branch_name: '{{ current_task_branch }}'
            {% endif %}

            # Salt pillars.

            '{{ project_name }}-salt-pillars':
                git:
                    source_system_host: '{{ master_minion_id }}'

                    origin_uri_ssh_path: 'Works/{{ project_name }}-salt-pillars.git'

                    branch_name: '{{ profile_name }}'

            '{{ project_name }}-salt-pillars.bootstrap-target':
                git:
                    source_system_host: '{{ master_minion_id }}'

                    origin_uri_ssh_path: 'Works/{{ project_name }}-salt-pillars.bootstrap-target.git'

                    branch_name: '{{ profile_name }}'

            # Maven component repositories.

            {% for maven_repo_name in maven_repo_names %}

            '{{ maven_repo_name }}':
                git:
                    source_system_host: '{{ master_minion_id }}'

                    origin_uri_ssh_path: 'Works/{{ maven_repo_name }}.git'

                    branch_name: 'develop'

            {% endfor %}

            # Other repositories.

            # ...

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

