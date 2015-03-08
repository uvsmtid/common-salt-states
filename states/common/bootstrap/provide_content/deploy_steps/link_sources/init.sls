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

{% set bootstrap_platform = target_env_pillar['system_hosts'][selected_host_name]['bootstrap_platform'] %}

# Configuration for the step.
{% set archive_dir_path_in_config = 'resources/sources/' + project_name + '/' + profile_name %}
{% set archive_dir_path = bootstrap_dir + '/' + archive_dir_path_in_config %}
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
                        'exported_source_archive': '{{ archive_dir_path_in_config }}/{{ selected_repo_name }}.tar',
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

# Create base dir for all soruces.
{{ requisite_config_file_id }}_{{ deploy_step }}_sources_dir:
    file.directory:
        - name: '{{ archive_dir_path }}'
        - makedirs: True
        - mode: 755
        - user: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'

# Import shared marco.
{# Call marco `define_git_repo_uri` to define variable `git_repo_uri`. #}
{% from 'common/git/git_uri.lib.sls' import define_git_repo_uri with context %}

# Generate archives with sources.
{% for selected_repo_name in target_env_pillar['system_features']['bootstrap_configuration']['export_sources_repos'].keys() %} # selected_repo_name

{% set selected_repo_type = target_env_pillar['system_features']['deploy_environment_sources']['source_repo_types'][selected_repo_name] %}

{% if selected_repo_type == 'git' %} # Git SCM

{% set git_repo_uri = define_git_repo_uri(selected_repo_name) %}

{% set repo_config = target_env_pillar['system_features']['deploy_environment_sources']['source_repositories'][selected_repo_name][selected_repo_type] %}

# Create archive.
{{ requisite_config_file_id }}_{{ deploy_step }}_extract_sources_{{ selected_repo_name }}:
    cmd.run:
        - name: 'git archive --format tar --output="{{ archive_dir_path }}/{{ selected_repo_name }}.tar" --remote="{{ git_repo_uri }}" "{{ repo_config['branch_name'] }}"'
        # User and Group are from source env pillar - where the package is build.
        - user: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - require:
            - file: {{ requisite_config_file_id }}_{{ deploy_step }}_sources_dir
{% endif %} # Git SCM

# Rewrite `target_env_pillar`.
# See:
#   http://stackoverflow.com/q/11047886/441652
#   http://stackoverflow.com/a/3479970/441652
{% set URI_prefix_saved = target_env_pillar['registered_content_config']['URI_prefix'] %}
# TODO: Resource location should be adjusted trough symlinks just like symlinks to sources.
#       At the moment all resources during `deploy` appear in
#       `resources/{{ project_name }} ` directory.
{% do target_env_pillar['registered_content_config'].update({ 'URI_prefix': 'salt://source_roots/{{ selected_repo_name }}/resources/{{ project_name }}' }) %}
{% set base_dir = bootstrap_dir + '/resources/rewritten_pillars/' + project_name + '/' + profile_name %}
{{ requisite_config_file_id }}_{{ deploy_step }}_extract_sources_{{ selected_repo_name }}_rewirte_pillar:
    file.managed:
        # Note that location of the pillar is _assumed_.
        # TODO: Make location of the pillar declared, otherwise if pillar is
        #       located in different place, rewrite will be merge with
        #       unpredictable results.
        - name: '{{ base_dir }}/pillars/{{ project_name }}/{{ profile_name }}.sls'
        - source: ~
        - makedirs: True
        # Render `target_env_pillar` as JSON.
        - contents: |
            {{ target_env_pillar }}
        - require:
            - cmd: {{ requisite_config_file_id }}_{{ deploy_step }}_extract_sources_{{ selected_repo_name }}

# Change target pillar back.
{% do target_env_pillar['registered_content_config'].update({ 'URI_prefix': URI_prefix_saved }) %}

# Add the rewritten `target_env_pillar` to the initial archive.
{{ requisite_config_file_id }}_{{ deploy_step }}_extract_sources_{{ selected_repo_name }}_add_rewritten_pillar:
    cmd.run:
        - name: 'tar -rvf {{ archive_dir_path }}/{{ selected_repo_name }}.tar pillars/{{ project_name }}/{{ profile_name }}.sls'
        # Tar always work in current directory.
        - cwd: '{{ base_dir }}'
        - require:
            - file: {{ requisite_config_file_id }}_{{ deploy_step }}_extract_sources_{{ selected_repo_name }}_rewirte_pillar
            - cmd: {{ requisite_config_file_id }}_{{ deploy_step }}_extract_sources_{{ selected_repo_name }}

{% if selected_repo_type != 'git' %} # ! Git SCM
    {{ FAIL_this_template_instantiation_unsupported_SCM }}
{% endif %} # ! Git SCM

{% endfor %} # selected_repo_name

{% endmacro %}

