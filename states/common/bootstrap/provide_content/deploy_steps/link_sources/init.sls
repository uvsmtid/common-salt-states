#

{% macro configure_deploy_step_function(
        source_env_pillar
        ,
        target_env_pillar
        ,
        selected_host_name
        ,
        deploy_step
        ,
        deploy_step_config
        ,
        project_name
        ,
        profile_name
        ,
        requisite_config_file_id
        ,
        requisite_config_file_path
        ,
        bootstrap_dir
    )
%}

{{ requisite_config_file_id }}_{{ deploy_step }}:
    file.blockreplace:
        - name: '{{ requisite_config_file_path }}'
        - marker_start: '# Salt auto-config START: {{ requisite_config_file_id }}_{{ deploy_step }}'
        - marker_end:   '# Salt auto-config END:   {{ requisite_config_file_id }}_{{ deploy_step }}'
        - append_if_not_found: True
        - backup: False
        - content: |
            {{ deploy_step }} = {
                'step_enabled': {{ deploy_step_config['step_enabled'] }},
                # Configure each extracted respository.
                'repos': {
            {% for selected_repo_name in target_env_pillar['system_features']['bootstrap_configuration']['export_sources_repos'].keys() %} # selected_repo_name
            {% set selected_repo_type = target_env_pillar['system_features']['deploy_environment_sources']['source_repo_types'][selected_repo_name] %}
            {% if selected_repo_type == 'git' %} # Git SCM
            {% set repo_config = target_env_pillar['system_features']['deploy_environment_sources']['source_repositories'][selected_repo_name][selected_repo_type] %}
                    '{{ selected_repo_name }}': {
                        'repo_type': '{{ selected_repo_type }}',
                        'archive_type': 'tar',
                    },
            {% endif %} # Git SCM
            {% if selected_repo_type != 'git' %} # ! Git SCM
                {{ FAIL_this_template_instantiation_unsupported_SCM }}
            {% endif %} # ! Git SCM
            {% endfor %} # selected_repo_name
                },

            }
        - show_changes: True
        - require:
            - file: {{ requisite_config_file_id }}

{{ requisite_config_file_id }}_{{ deploy_step }}_sources_dir:
    file.directory:
        - mode: 755
        - user: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'

{# Call marco `define_git_repo_uri` to define variable `git_repo_uri`. #}
{% from 'common/git/git_uri.lib.sls' import define_git_repo_uri with context %}

{% for selected_repo_name in target_env_pillar['system_features']['bootstrap_configuration']['export_sources_repos'].keys() %} # selected_repo_name

{% set selected_repo_type = target_env_pillar['system_features']['deploy_environment_sources']['source_repo_types'][selected_repo_name] %}

{% if selected_repo_type == 'git' %} # Git SCM

{% set git_repo_uri = define_git_repo_uri(selected_repo_name) %}

{% set repo_config = target_env_pillar['system_features']['deploy_environment_sources']['source_repositories'][selected_repo_name][selected_repo_type] %}

{{ requisite_config_file_id }}_{{ deploy_step }}_extract_sources_{{ selected_repo_name }}:
    cmd.run:
        # User and Group are from source env pillar - where the package is build.
        - user: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - require:
            - file: {{ requisite_config_file_id }}_{{ deploy_step }}_sources_dir
{% endif %} # Git SCM

{% if selected_repo_type != 'git' %} # ! Git SCM
    {{ FAIL_this_template_instantiation_unsupported_SCM }}
{% endif %} # ! Git SCM

{% endfor %} # selected_repo_name

{% endmacro %}

