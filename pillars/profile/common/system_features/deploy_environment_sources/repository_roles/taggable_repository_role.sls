
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

        repository_roles:

            taggable_repository_role:
                - '{{ project_name }}-salt-states'
                - '{{ project_name }}-build-history'
                {% if props['parent_repo_name'] %}
                - {{ props['parent_repo_name'] }}
                {% endif %}

###############################################################################
# EOF
###############################################################################

