
###############################################################################

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

{% set resources_macro_lib = 'common/resource_symlinks/resources_macro_lib.sls' %}
{% from resources_macro_lib import get_registered_content_item_URI_from_pillar with context %}
{% from resources_macro_lib import get_registered_content_item_base_name_from_pillar with context %}
{% from resources_macro_lib import get_registered_content_item_hash_from_pillar with context %}

# Config for the step.
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
                'yum_main_config': 'resources/conf/{{ project_name }}/{{ profile_name }}/{{ selected_host_name }}/yum.conf',
                'platform_repos_list': 'resources/conf/{{ project_name }}/{{ profile_name }}/{{ selected_host_name }}/platform_repos_list.repo',

                {% set os_platform_yum_configs = target_env_pillar['system_features']['yum_repos_configuration'] %}
                {% set os_platform = target_env_pillar['system_hosts'][selected_host_name]['os_platform'] %}
                'yum_repo_configs': {
                {% for yum_repo_config_name in os_platform_yum_configs['yum_repositories'].keys() %}
                {% if os_platform in os_platform_yum_configs['yum_repositories'][yum_repo_config_name]['os_platform_configs'] %}
                {% set yum_repo_config = os_platform_yum_configs['yum_repositories'][yum_repo_config_name]['os_platform_configs'][os_platform] %}
                {% if 'key_file_resource_id' in yum_repo_config %}
                    '{{ yum_repo_config_name }}': {
                        {% set file_path = get_registered_content_item_base_name_from_pillar(yum_repo_config['key_file_resource_id'], target_env_pillar) %}
                        'key_file_resource_path': 'resources/conf/{{ project_name }}/{{ profile_name }}/{{ selected_host_name }}/yums/{{ yum_repo_config_name }}/{{ file_path }}',
                        'key_file_path': '{{ yum_repo_config['key_file_path'] }}'
                    },
                {% endif %}
                {% endif %}
                {% endfor %}
                },

            }
        - show_changes: True
        - require:
            - file: {{ requisite_config_file_id }}

# Save resource.
{% set os_platform_yum_configs = target_env_pillar['system_features']['yum_repos_configuration'] %}
{% set os_platform = target_env_pillar['system_hosts'][selected_host_name]['os_platform'] %}

{% for yum_repo_config_name in os_platform_yum_configs['yum_repositories'].keys() %}
{% if os_platform in os_platform_yum_configs['yum_repositories'][yum_repo_config_name]['os_platform_configs'] %}

{% set yum_repo_config = os_platform_yum_configs['yum_repositories'][yum_repo_config_name]['os_platform_configs'][os_platform] %}

{% if 'key_file_resource_id' in yum_repo_config %}
{{ requisite_config_file_id }}_{{ deploy_step }}_{{ os_platform }}_{{ yum_repo_config_name }}:
    file.managed:
        {% set file_path = get_registered_content_item_base_name_from_pillar(yum_repo_config['key_file_resource_id'], target_env_pillar) %}
        - name: '{{ target_contents_dir }}/resources/conf/{{ project_name }}/{{ profile_name }}/{{ selected_host_name }}/yums/{{ yum_repo_config_name }}/{{ file_path }}'
        - source: '{{ get_registered_content_item_URI_from_pillar(yum_repo_config['key_file_resource_id'], target_env_pillar) }}'
        - source_has: '{{ get_registered_content_item_hash_from_pillar(yum_repo_config['key_file_resource_id'], target_env_pillar) }}'
        - template: ~
        - makedirs: True
        - user: '{{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}'
{% endif %}
{% endif %}
{% endfor %}

# Instantiate template for `platform_repos_list.repo`.
{{ requisite_config_file_id }}_{{ deploy_step }}_platform_repos_list:
    file.managed:
        - name: '{{ target_contents_dir }}/resources/conf/{{ project_name }}/{{ profile_name }}/{{ selected_host_name }}/platform_repos_list.repo'
        - source: '{{ target_env_pillar['system_features']['static_bootstrap_configuration']['deploy_steps_params']['init_yum_repos']['platform_repos_list_template'] }}'
        - template: jinja
        - makedirs: True
        - context:
            selected_pillar: {{ target_env_pillar }}
            host_config: {{ target_env_pillar['system_hosts'][selected_host_name] }}
        - makedirs: True
        - group: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - user: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'

# Instantiate template for `yum.conf`.
{{ requisite_config_file_id }}_{{ deploy_step }}_yum.conf:
    file.managed:
        - name: '{{ target_contents_dir }}/resources/conf/{{ project_name }}/{{ profile_name }}/{{ selected_host_name }}/yum.conf'
        - source: '{{ deploy_step_config['yum_main_config_template'] }}'
        - template: jinja
        - makedirs: True
        - context:
            selected_pillar: {{ target_env_pillar }}
        - group: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - user: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'

{% endmacro %}

