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

{% set resources_macro_lib = 'common/resource_symlinks/resources_macro_lib.sls' %}
{% from resources_macro_lib import get_URI_scheme_abs_links_base_dir_path_from_pillar with context %}
{% from resources_macro_lib import get_registered_content_item_rel_path_from_pillar with context %}
{% from resources_macro_lib import get_registered_content_item_URI_from_pillar with context %}

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
                "src_salt_online_config_file": "resources/conf/{{ project_name }}/{{ profile_name }}/{{ selected_host_name }}/minion.online.conf",
                "src_salt_offline_config_file": "resources/conf/{{ project_name }}/{{ profile_name }}/{{ selected_host_name }}/minion.offline.conf",
                "dst_salt_config_file": "/etc/salt/minion",
                "rpm_sources": {
                    {% for rpm_source_name in deploy_step_config['salt_minion_rpm_sources'][os_platform].keys() %}
                    {% set rpm_source_config = deploy_step_config['salt_minion_rpm_sources'][os_platform][rpm_source_name] %}
                    {% if rpm_source_config['source_type'] %}
                    {% set file_path = get_registered_content_item_rel_path_from_pillar(rpm_source_config['resource_id'], target_env_pillar) %}
                    "{{ rpm_source_name }}": {
                        "source_type": "{{ rpm_source_config['source_type'] }}",
                        # Note that all resources are shared per project (no profile sub-directory).
                        "file_path": "resources/bootstrap/{{ project_name }}/{{ profile_name }}/{{ file_path }}",
                    },
                    {% endif %}
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
        - name: '{{ target_contents_dir }}/resources/conf/{{ project_name }}/{{ profile_name }}/{{ selected_host_name }}/minion.{{ minion_type }}.conf'
        - source: '{{ deploy_step_config[salt_minion_template] }}'
        - context:
            project_name: '{{ project_name }}'
            profile_name: '{{ profile_name }}'
            selected_host_name: '{{ selected_host_name }}'
            resources_links_dir: '{{ get_URI_scheme_abs_links_base_dir_path_from_pillar('salt://', target_env_pillar) }}'
        - template: jinja
        - makedirs: True
        - user: '{{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}'
{% endfor %}

# Resources used by the step.
{% for rpm_source_name in deploy_step_config['salt_minion_rpm_sources'][os_platform].keys() %}
{% set rpm_source_config = deploy_step_config['salt_minion_rpm_sources'][os_platform][rpm_source_name] %}
{% if rpm_source_config['source_type'] %}
{% set file_path = get_registered_content_item_rel_path_from_pillar(rpm_source_config['resource_id'], target_env_pillar) %}
{{ requisite_config_file_id }}_{{ deploy_step }}_depository_item_{{ rpm_source_name }}:
    file.managed:
        # Note that all resources are shared per project (no profile sub-directory).
        - name: '{{ target_contents_dir }}/resources/bootstrap/{{ project_name }}/{{ profile_name }}/{{ file_path }}'
        - source: '{{ get_registered_content_item_URI_from_pillar(rpm_source_config['resource_id'], target_env_pillar) }}'
        - template: ~
        - makedirs: True
        - user: '{{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}'
{% endif %}
{% endfor %}

{% endmacro %}
