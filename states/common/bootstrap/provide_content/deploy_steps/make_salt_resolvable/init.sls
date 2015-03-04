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
            make_salt_resolvable = {
                'required_entries_hosts_file': 'resources/examples/uvsmtid/centos-5.5-minimal/hosts_file',
            }
        - show_changes: True
        - require:
            - file: {{ requisite_config_file_id }}

{% endmacro %}

