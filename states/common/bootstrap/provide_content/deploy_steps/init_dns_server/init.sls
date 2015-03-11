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
                'resolv_conf_file': 'resources/conf/{{ project_name }}/{{ profile_name }}/{{ selected_host_name }}/resolv.conf',
                'dns_server_ip': '{{ target_env_pillar['internal_net']['dns_server'] }}',
                'remote_hostname': '{{ target_env_pillar['internal_net']['resolvable_hostname'] }}',
            }
        - show_changes: True
        - require:
            - file: {{ requisite_config_file_id }}

{{ requisite_config_file_id }}_{{ deploy_step }}_resolv.conf:
    file.managed:
        - name: '{{ bootstrap_dir }}/resources/conf/{{ project_name }}/{{ profile_name }}/{{ selected_host_name }}/resolv.conf'
        - source: '{{ deploy_step_config['resolv_conf_template'] }}'
        - template: jinja
        - makedirs: True
        - context:
            selected_pillar: {{ target_env_pillar }}
        - group: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - user: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'

{% endmacro %}

