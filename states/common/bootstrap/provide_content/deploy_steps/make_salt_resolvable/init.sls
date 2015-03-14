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
                'required_entries_hosts_file': 'resources/conf/{{ project_name }}/{{ profile_name }}/{{ selected_host_name }}/hosts_file',
            }
        - show_changes: True
        - require:
            - file: {{ requisite_config_file_id }}

{% from 'common/libs/host_config_queries.sls' import get_role_ip_address_from_pillar with context %}

{{ requisite_config_file_id }}_{{ deploy_step }}_hosts_file:
    file.managed:
        - name: '{{ bootstrap_dir }}/resources/conf/{{ project_name }}/{{ profile_name }}/{{ selected_host_name }}/hosts_file'
        - makedirs: True
        - contents: |
            {{ get_role_ip_address_from_pillar('controller_role', target_env_pillar) }} salt
        - group: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - user: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'

{% endmacro %}

