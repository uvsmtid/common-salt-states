
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

            # Repository with build history.

            '{{ project_name }}-build-history': git

            # Maven repositories.

            {% for maven_repo_name in maven_repo_names %}

            '{{ maven_repo_name }}': git

            {% endfor %}

            # Other repositories.

            # ...

###############################################################################
# EOF
###############################################################################

