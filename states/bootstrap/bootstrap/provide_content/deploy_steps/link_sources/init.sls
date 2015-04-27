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

{% from 'common/libs/host_config_queries.sls' import get_system_host_primary_user_posix_home_from_pillar with context %}

# Configuration for the step.
{% set export_dir_path_in_config = 'resources/sources/' + project_name + '/' + profile_name %}
{% set export_dir_path = target_contents_dir + '/' + export_dir_path_in_config %}
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
                # TODO: There can be multiple sources of states (i.e. in
                #       multi-project case. Figure out how to make it generic.
                'salt_states_sources': '{{ target_env_pillar['system_features']['bootstrap_configuration']['bootstrap_sources']['states'] }}',
                'salt_pillars_sources': '{{ target_env_pillar['system_features']['bootstrap_configuration']['bootstrap_sources']['pillars'] }}',
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
            {% set export_format = source_env_pillar['system_features']['bootstrap_configuration']['export_sources'][selected_repo_name]['export_format'] %}
                    '{{ selected_repo_name }}': {
                        'repo_type': '{{ selected_repo_type }}',
                        'export_format': '{{ export_format }}',
                        # In online system, sources are on specific remote
                        # host (likely Salt master).
                        'online_destination_dir': '{{ get_system_host_primary_user_posix_home_from_pillar(repo_config['source_system_host'], target_env_pillar) }}/{{ repo_config['origin_uri_ssh_path'] }}',
                        # In offline system, each minion has its own sources.
                        'offline_destination_dir': '{{ get_system_host_primary_user_posix_home_from_pillar(selected_host_name, target_env_pillar) }}/{{ repo_config['origin_uri_ssh_path'] }}',
            {% if not export_format %}
                        {{ FAIL_no_export_format_specified }}
            {% elif export_format == 'tar' %}
                        'exported_source_archive': '{{ export_dir_path_in_config }}/{{ selected_repo_name }}.tar',
            {% elif export_format == 'dir' %}
                        'exported_source_archive': '{{ export_dir_path_in_config }}/{{ selected_repo_name }}',
            {% else %}
                        {{ FAIL_unknown_export_format }}
            {% endif %}
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
        - name: '{{ export_dir_path }}'
        - makedirs: True
        - mode: 755
        - user: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'

# Import shared marco.
{# Call marco `define_git_repo_uri` to define variable `git_repo_uri`. #}
{% from 'common/git/git_uri.lib.sls' import define_git_repo_uri with context %}

# Generate exports with sources.

# NOTE: The loop goes through each defined repo because exports are created
#       for each repos. If repo is not enabled, empty export is created.
{% for selected_repo_name in target_env_pillar['system_features']['deploy_environment_sources']['source_repositories'].keys() %} # selected_repo_name

{% set selected_repo_type = target_env_pillar['system_features']['deploy_environment_sources']['source_repo_types'][selected_repo_name] %}

{% if selected_repo_type == 'git' %} # Git SCM

{% set git_repo_uri = define_git_repo_uri(selected_repo_name) %}

# NOTE: We use `bootstrap_configuration` of `source_env_pillar`.
#       This uses sources names and branches as they exists
#       in current environment.
{% if selected_repo_name in source_env_pillar['system_features']['bootstrap_configuration']['export_sources'].keys() %} # selected_repo_name

{% set branch_name = source_env_pillar['system_features']['bootstrap_configuration']['export_sources'][selected_repo_name]['branch_name'] %}
{% set export_enabled = source_env_pillar['system_features']['bootstrap_configuration']['export_sources'][selected_repo_name]['export_enabled'] %}
{% set export_method = source_env_pillar['system_features']['bootstrap_configuration']['export_sources'][selected_repo_name]['export_method'] %}

{% set source_system_host = source_env_pillar['system_features']['deploy_environment_sources']['source_repositories'][selected_repo_name]['git']['source_system_host'] %}
{% set origin_uri_ssh_path = source_env_pillar['system_features']['deploy_environment_sources']['source_repositories'][selected_repo_name]['git']['origin_uri_ssh_path'] %}

{% if export_enabled %} # export_enabled

# Create export.
{{ requisite_config_file_id }}_{{ deploy_step }}_extract_sources_{{ selected_repo_name }}:
    cmd.run:

    {% if not export_method %}
        {{ FAIL_no_export_method_specified }}
    {% elif export_method == 'git-archive' %}
        - name: 'git archive --format tar --output="{{ export_dir_path }}/{{ selected_repo_name }}.tar" --remote="{{ git_repo_uri }}" "{{ branch_name }}"'
    {% elif export_method == 'checkout-index' %}
    {% set base_repo_dir = source_env_pillar['system_hosts'][source_system_host]['primary_user']['posix_user_home_dir'] %}
        - name: 'git checkout-index --all --force --prefix="{{ export_dir_path }}/{{ selected_repo_name }}/{{ selected_repo_name }}/"'
        # Repository location on local file system:
        - cwd: '{{ base_repo_dir }}/{{ origin_uri_ssh_path }}'
    {% else %}
        {{ FAIL_unknown_export_method }}
    {% endif %}
        # User and Group are from source env pillar - where the package is build.
        - user: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - require:
            - file: {{ requisite_config_file_id }}_{{ deploy_step }}_sources_dir

{% else %} # export_enabled

# Create an empty export.
{{ requisite_config_file_id }}_{{ deploy_step }}_extract_sources_{{ selected_repo_name }}:
    cmd.run:
    {% if not export_method %}
        {{ FAIL_no_export_method_specified }}
    {% elif export_method == 'git-archive' %}
        - name: 'tar -c -T /dev/null -f "{{ export_dir_path }}/{{ selected_repo_name }}.tar"'
    {% elif export_method == 'checkout-index' %}
    {% set base_repo_dir = source_env_pillar['system_hosts'][source_system_host]['primary_user']['posix_user_home_dir'] %}
        - name: 'mkdir -p "{{ export_dir_path }}/{{ selected_repo_name }}/{{ selected_repo_name }}"'
        # Repository location on local file system:
        - cwd: '{{ base_repo_dir }}/{{ origin_uri_ssh_path }}'
    {% else %}
        {{ FAIL_unknown_export_method }}
    {% endif %}
        # User and Group are from source env pillar - where the package is build.
        - user: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - require:
            - file: {{ requisite_config_file_id }}_{{ deploy_step }}_sources_dir

{% endif %} # export_enabled

{% else %} # selected_repo_name

    {{ FAIL_undefined_export_source }}

{% endif %} # selected_repo_name

{% endif %} # Git SCM

{% if selected_repo_type != 'git' %} # ! Git SCM
    {{ FAIL_this_template_instantiation_unsupported_SCM }}
{% endif %} # ! Git SCM

{% endfor %} # selected_repo_name

{% endmacro %}

