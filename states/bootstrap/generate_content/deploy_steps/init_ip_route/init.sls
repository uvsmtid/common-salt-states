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

{% set net_host_resolved_in = target_env_pillar['system_hosts'][selected_host_name]['resolved_in'] %}

set_config_{{ requisite_config_file_id }}_{{ deploy_step }}:
    file.blockreplace:
        - name: '{{ requisite_config_file_path }}'
        - marker_start: '# Salt auto-config START: {{ requisite_config_file_id }}_{{ deploy_step }}'
        - marker_end:   '# Salt auto-config END:   {{ requisite_config_file_id }}_{{ deploy_step }}'
        - append_if_not_found: True
        - backup: False
        - content: |
            {{ deploy_step }} = {
                'step_enabled': {{ deploy_step_config['step_enabled'] }},
                # IP address to route IP traffic by default.
                'default_route_ip': '{{ target_env_pillar['system_networks'][net_host_resolved_in]['gateway'] }}',
                # IP address behind network router to confirm successful routing configuration.
                # Use `external_dns_server` for bootstrap at the moment
                # even if it is not necessarily outside of current network.
                # TODO: Should we add config for IP surely outside current network?
                'remote_network_ip': '{{ target_env_pillar['system_features']['hostname_resolution_config']['external_dns_server'] }}',
            }
        - show_changes: True
        - require:
            - file: req_file_{{ requisite_config_file_id }}

{% endmacro %}

