# Macro for installing Jenkins plugin.

{% macro jenkins_plugin_installation_macros(registered_content_item_id) %}

{% if pillar['registered_content_items'][registered_content_item_id]['enable_installation'] %}

{% set URI_prefix = pillar['registered_content_config']['URI_prefix'] %}

{% set config_temp_dir = pillar['posix_config_temp_dir'] %}
{% set jenkins_master_hostname = pillar['system_hosts'][pillar['system_host_roles']['jenkins_master_role']['assigned_hosts'][0]]['hostname'] %}
{% set plugin_name = pillar['registered_content_items'][registered_content_item_id]['plugin_name'] %}

'{{ config_temp_dir }}/{{ pillar['registered_content_items'][registered_content_item_id]['item_base_name'] }}':
    file.managed:
        - source: '{{ URI_prefix }}/{{ pillar['registered_content_items'][registered_content_item_id]['item_parent_dir_path'] }}/{{ pillar['registered_content_items'][registered_content_item_id]['item_base_name'] }}'
        - source_hash: {{ pillar['registered_content_items'][registered_content_item_id]['item_content_hash'] }}
        - makedirs: True

install_jenkins_{{ registered_content_item_id }}:
    cmd.run:
        - name: 'java -jar {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:8080/ install-plugin {{ config_temp_dir }}/{{ pillar['registered_content_items'][registered_content_item_id]['item_base_name'] }} -restart'
        - unless: 'java -jar {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:8080/ list-plugins {{ plugin_name }} | grep {{ plugin_name }}'
        - require:
            - cmd: '{{ registered_content_item_id }}_jenkins_plugin_installation_prerequisite'
            - file: '{{ config_temp_dir }}/{{ pillar['registered_content_items'][registered_content_item_id]['item_base_name'] }}'

{% endif %}

{% endmacro %}


