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

{% set bootstrap_platform = target_env_pillar['system_hosts'][selected_host_name]['bootstrap_platform'] %}

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
                "step_enabled": {{ deploy_step_config['step_enabled'] }},
                "src_salt_online_config_file": "resources/{{ project_name }}/{{ profile_name }}/conf/minion.online.conf",
                "src_salt_offline_config_file": "resources/{{ project_name }}/{{ profile_name }}/conf/minion.offline.conf",
                "dst_salt_config_file": "/etc/salt/minion",
                "rpm_sources": {
                    {% for rpm_source_name in deploy_step_config['salt_minion_rpm_sources'][bootstrap_platform].keys() %}
                    {% set rpm_source_config = deploy_step_config['salt_minion_rpm_sources'][bootstrap_platform][rpm_source_name] %}
                    {% set resource_item_config = target_env_pillar['registered_content_items'][rpm_source_config['resource_id']] %}
                    {% set file_path = resource_item_config['item_parent_dir_path'] + '/' + resource_item_config['item_base_name'] %}
                    "{{ rpm_source_name }}": {
                        "source_type": "{{ rpm_source_config['source_type'] }}",
                        # Note that all resources are shared per project (no profile sub-directory).
                        "file_path": "resources/{{ project_name }}/depository/{{ file_path }}",
                    },
                    {% endfor %}
                },
            }
        - show_changes: True
        - require:
            - file: {{ requisite_config_file_id }}

# Pre-build config files used by the step.
{% for minion_type in [ 'online', 'offline' ] %}
{% set salt_minion_template = 'salt_minion_' + minion_type + '_template' %}
{{ requisite_config_file_id }}_{{ deploy_step }}_salt_minion_{{ minion_type }}_config_file:
    file.managed:
        - name: '{{ bootstrap_dir }}/resources/{{ project_name }}/{{ profile_name }}/conf/minion.{{ minion_type }}.conf'
        - source: '{{ deploy_step_config[salt_minion_template] }}'
        - context:
            project_name: '{{ project_name }}'
            profile_name: '{{ profile_name }}'
            selected_host_name: '{{ selected_host_name }}'
        - template: jinja
        - makedirs: True
        - user: '{{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}'
{% endfor %}

# Resources used by the step.
{% set URI_prefix = target_env_pillar['registered_content_config']['URI_prefix'] %}
{% for rpm_source_name in deploy_step_config['salt_minion_rpm_sources'][bootstrap_platform].keys() %}
{% set rpm_source_config = deploy_step_config['salt_minion_rpm_sources'][bootstrap_platform][rpm_source_name] %}
{% set resource_item_config = target_env_pillar['registered_content_items'][rpm_source_config['resource_id']] %}
{% set file_path = resource_item_config['item_parent_dir_path'] + '/' + resource_item_config['item_base_name'] %}
{{ requisite_config_file_id }}_{{ deploy_step }}_depository_item_{{ rpm_source_name }}:
    file.managed:
        # Note that all resources are shared per project (no profile sub-directory).
        - name: '{{ bootstrap_dir }}/resources/{{ project_name }}/depository/{{ file_path }}'
        - source: '{{ URI_prefix }}/{{ file_path }}'
        - template: ~
        - makedirs: True
        - user: '{{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}'
{% endfor %}

{% endmacro %}

