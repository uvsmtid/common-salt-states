
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set project_name = props['project_name'] %}
{% set master_minion_id = props['master_minion_id'] %}
{% set profile_name = props['profile_name'] %}

system_features:

    deploy_environment_sources:

        source_repositories:

            # Main repository with submodules.

            {% if props['parent_repo_name'] %}

            '{{ props['parent_repo_name'] }}':
                git:
                    source_system_host: '{{ master_minion_id }}'

                    origin_uri_ssh_path: 'Works/{{ props['parent_repo_name'] }}.git'

            {% endif %}

###############################################################################
# EOF
###############################################################################

