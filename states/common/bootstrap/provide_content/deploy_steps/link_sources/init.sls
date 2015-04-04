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
        target_contents_dir
        ,
        bootstrap_dir
    )
%}

{% set os_platform = target_env_pillar['system_hosts'][selected_host_name]['os_platform'] %}

# The base_dir is in "rewritten_pillars" only for running `tar` command.
{% set base_dir = target_contents_dir + '/resources/rewritten_pillars/' + project_name + '/' + profile_name %}

{% from 'common/libs/host_config_queries.sls' import get_system_host_primary_user_posix_home_from_pillar with context %}

# Configuration for the step.
{% set archive_dir_path_in_config = 'resources/sources/' + project_name + '/' + profile_name %}
{% set archive_dir_path = target_contents_dir + '/' + archive_dir_path_in_config %}
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
                # TODO: This is hardcoded, figure out how to make it generic.
                # TODO: There can be multiple sources of states (i.e. in
                #       multi-project case. Figure out how to make it generic.
                'state_sources': 'common-salt-states',
                # Configure each extracted respository.
                'repos': {
            # NOTE: We put all repos in configuration but generate empty
            #       archives for those which are not part of
            #         target_env_pillar['system_features']['bootstrap_configuration']['export_sources']
            #       This is one way to make sure `common.source_symlinks` will
            #       be able to create symlinks to the repositories.
            {% for selected_repo_name in target_env_pillar['system_features']['deploy_environment_sources']['source_repositories'].keys() %} # selected_repo_name
            {% set selected_repo_type = target_env_pillar['system_features']['deploy_environment_sources']['source_repo_types'][selected_repo_name] %}
            {% if selected_repo_type == 'git' %} # Git SCM
            {% set repo_config = target_env_pillar['system_features']['deploy_environment_sources']['source_repositories'][selected_repo_name][selected_repo_type] %}
                    '{{ selected_repo_name }}': {
                        'repo_type': '{{ selected_repo_type }}',
                        'archive_type': 'tar',
                        # In online system, sources are on specific remote
                        # host (likely Salt master).
                        'online_destination_dir': '{{ get_system_host_primary_user_posix_home_from_pillar(repo_config['source_system_host'], target_env_pillar) }}/{{ repo_config['origin_uri_ssh_path'] }}',
                        # In offline system, each minion has its own sources.
                        'offline_destination_dir': '{{ get_system_host_primary_user_posix_home_from_pillar(selected_host_name, target_env_pillar) }}/{{ repo_config['origin_uri_ssh_path'] }}',
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

# NOTE: The loop goes through each defined repo because archives are created
#       for each repos. If repo is not enabled, empty archive is created.
{% for selected_repo_name in target_env_pillar['system_features']['deploy_environment_sources']['source_repositories'].keys() %} # selected_repo_name

{% set selected_repo_type = target_env_pillar['system_features']['deploy_environment_sources']['source_repo_types'][selected_repo_name] %}

{% if selected_repo_type == 'git' %} # Git SCM

{% set git_repo_uri = define_git_repo_uri(selected_repo_name) %}

{% if selected_repo_name in target_env_pillar['system_features']['bootstrap_configuration']['export_sources'].keys() %}

{% set branch_name = target_env_pillar['system_features']['bootstrap_configuration']['export_sources'][selected_repo_name]['branch_name'] %}

# Create archive.
{{ requisite_config_file_id }}_{{ deploy_step }}_extract_sources_{{ selected_repo_name }}:
    cmd.run:
        - name: 'git archive --format tar --output="{{ archive_dir_path }}/{{ selected_repo_name }}.tar" --remote="{{ git_repo_uri }}" "{{ branch_name }}"'
        # User and Group are from source env pillar - where the package is build.
        - user: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - require:
            - file: {{ requisite_config_file_id }}_{{ deploy_step }}_sources_dir
{% else %}
# Create an empty archive.
{{ requisite_config_file_id }}_{{ deploy_step }}_extract_sources_{{ selected_repo_name }}:
    cmd.run:
        - name: 'tar -c -T /dev/null -f "{{ archive_dir_path }}/{{ selected_repo_name }}.tar"'
        # User and Group are from source env pillar - where the package is build.
        - user: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - require:
            - file: {{ requisite_config_file_id }}_{{ deploy_step }}_sources_dir
{% endif %}

{% endif %} # Git SCM

{% if selected_repo_type != 'git' %} # ! Git SCM
    {{ FAIL_this_template_instantiation_unsupported_SCM }}
{% endif %} # ! Git SCM

{% endfor %} # selected_repo_name

{% endmacro %}

