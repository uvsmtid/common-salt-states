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
                'resolv_conf_file': 'resources/conf/{{ project_name }}/{{ profile_name }}/{{ selected_host_name }}/resolv.conf',
                # Regardless of the `dns_server_type`, use `external_dns_server`
                # for bootstrap because it should be accessible anyway.
                # Salt stateswill reconfigure host settings, if `resolver_role`
                # is supposed to be used.
                'dns_server_ip': '{{ target_env_pillar['system_features']['hostname_resolution_config']['external_dns_server'] }}',
                'remote_hostname': '{{ target_env_pillar['system_features']['hostname_resolution_config']['resolvable_hostname'] }}',
            }
        - show_changes: True
        - require:
            - file: req_file_{{ requisite_config_file_id }}

config_file_{{ requisite_config_file_id }}_{{ deploy_step }}_resolv.conf:
    file.managed:
        - name: '{{ target_contents_dir }}/resources/conf/{{ project_name }}/{{ profile_name }}/{{ selected_host_name }}/resolv.conf'
        - source: '{{ deploy_step_config['resolv_conf_template'] }}'
        - template: jinja
        - makedirs: True
        {% set account_conf = source_env_pillar['system_accounts'][ source_env_pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
        - context:
            selected_pillar: {{ target_env_pillar }}
        - group: '{{ account_conf['username'] }}'
        - user: '{{ account_conf['username'] }}'

{% endmacro %}

