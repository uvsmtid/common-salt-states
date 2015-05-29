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
                'primary_user': '{{ target_env_pillar['system_hosts'][selected_host_name]['primary_user']['username'] }}',
                'primary_group': '{{ target_env_pillar['system_hosts'][selected_host_name]['primary_user']['primary_group'] }}',
                {% if target_env_pillar['system_hosts'][selected_host_name]['primary_user']['enforce_password'] %}
                'user_password': '{{ target_env_pillar['system_hosts'][selected_host_name]['primary_user']['password'] }}',
                {% else %}
                'user_password': ~,
                {% endif %}
            }
        - show_changes: True
        - require:
            - file: {{ requisite_config_file_id }}

{% endmacro %}

