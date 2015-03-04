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
        project_name
        ,
        profile_name
        ,
        requisite_config_file_id
        ,
        requisite_config_file_path
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
            init_ip_route = {
                # IP address to route IP traffic by default.
                'default_route_ip': '{{ target_env_pillar['internal_net']['gateway'] }}',
                # IP address behind network router to confirm successful routing configuration.
                'remote_network_ip': '{{ target_env_pillar['internal_net']['dns_server'] }}',
            }
        - show_changes: True
        - require:
            - file: {{ requisite_config_file_id }}

{% endmacro %}

