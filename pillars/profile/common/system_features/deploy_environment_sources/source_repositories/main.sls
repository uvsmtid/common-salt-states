
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

    deploy_environment_sources:

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

            {% endif %}

            # Salt states.

            'common-salt-states':
                git:
                    source_system_host: '{{ master_minion_id }}'

                    origin_uri_ssh_path: 'Works/{{ props['parent_repo_name'] }}.git/salt/common-salt-states.git'

            {% if project_name != 'common' %}
            '{{ project_name }}-salt-states':
                git:
                    source_system_host: '{{ master_minion_id }}'

                    origin_uri_ssh_path: 'Works/{{ props['parent_repo_name'] }}.git/salt/{{ project_name }}-salt-states.git'

            {% endif %}

            # Salt resources.

            'common-salt-resources':
                git:
                    source_system_host: '{{ master_minion_id }}'

                    origin_uri_ssh_path: 'Works/{{ props['parent_repo_name'] }}.git/salt/common-salt-resources.git'

            {% if project_name != 'common' %}
            '{{ project_name }}-salt-resources':
                git:
                    source_system_host: '{{ master_minion_id }}'

                    origin_uri_ssh_path: 'Works/{{ props['parent_repo_name'] }}.git/salt/{{ project_name }}-salt-resources.git'

            {% endif %}

            # Salt pillars.

            '{{ project_name }}-salt-pillars':
                git:
                    source_system_host: '{{ master_minion_id }}'

                    origin_uri_ssh_path: 'Works/{{ props['parent_repo_name'] }}.git/salt/{{ project_name }}-salt-pillars.git'

            '{{ project_name }}-salt-pillars.bootstrap-target':
                git:
                    source_system_host: '{{ master_minion_id }}'

                    origin_uri_ssh_path: 'Works/{{ props['parent_repo_name'] }}.git/salt/{{ project_name }}-salt-pillars.bootstrap-target.git'

            # Repository with build history.

            '{{ project_name }}-build-history':
                git:
                    source_system_host: '{{ master_minion_id }}'

                    origin_uri_ssh_path: 'Works/{{ props['parent_repo_name'] }}.git/build-history.git'

            # Maven component repositories.

            {% for maven_repo_name in maven_repo_names %}

            '{{ maven_repo_name }}':
                git:
                    source_system_host: '{{ master_minion_id }}'

                    origin_uri_ssh_path: 'Works/{{ props['parent_repo_name'] }}.git/maven/{{ maven_repo_name }}.git'

            {% endfor %}

            # Other repositories.

            # ...

###############################################################################
# EOF
###############################################################################

