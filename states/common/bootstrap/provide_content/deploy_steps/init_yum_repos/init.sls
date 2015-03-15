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
                'yum_main_config': 'resources/conf/{{ project_name }}/{{ profile_name }}/{{ selected_host_name }}/yum.conf',
                'yum_repo_configs': {
                {% set os_platform = target_env_pillar['system_hosts'][selected_host_name]['os_platform'] %}
                {% for yum_repo_config_name in deploy_step_config['yum_repo_configs'][os_platform].keys() %}
                {% set yum_repo_config = deploy_step_config['yum_repo_configs'][os_platform][yum_repo_config_name] %}
                {% if yum_repo_config['installation_type'] %}
                    '{{ yum_repo_config_name }}': {
                        # TODO: Depending on installation type, there should be
                        #       either deployment of repo configuration files
                        #       or installation of RPM which configures these
                        #       repositories.
                        'installation_type': '{{ yum_repo_config['installation_type'] }}',
                        {% if yum_repo_config['rpm_key_file_resource_id'] %}
                        {% set content_conf = target_env_pillar['registered_content_items'][yum_repo_config['rpm_key_file_resource_id']] %}
                        # The RPM key file is not downloaded - it is part of
                        # resources which are supposed to be downloaded
                        # in separate step.
                        'rpm_key_file': 'resources/depository/{{ project_name }}/{{ profile_name }}/{{ content_conf['item_parent_dir_path'] }}/{{ content_conf['item_base_name'] }}'
                        {% endif %}
                    },
                {% endif %}
                {% endfor %}
                },
            }
        - show_changes: True
        - require:
            - file: {{ requisite_config_file_id }}

{{ requisite_config_file_id }}_{{ deploy_step }}_yum.conf:
    file.managed:
        - name: '{{ bootstrap_dir }}/resources/conf/{{ project_name }}/{{ profile_name }}/{{ selected_host_name }}/yum.conf'
        - source: '{{ deploy_step_config['yum_main_config_template'] }}'
        - template: jinja
        - makedirs: True
        - context:
            selected_pillar: {{ target_env_pillar }}
        - group: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - user: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'

{% endmacro %}

