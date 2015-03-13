# Macro for installing Jenkins plugin.

{% macro jenkins_plugin_installation_macros(registered_content_item_id) %}

{% if pillar['registered_content_items'][registered_content_item_id]['enable_installation'] %}

{% set resources_macro_lib = 'common/resource_symlinks/resources_macro_lib.sls' %}
{% from resources_macro_lib import get_registered_content_item_URI with context %}
{% from resources_macro_lib import get_registered_content_item_hash with context %}

{% set config_temp_dir = pillar['posix_config_temp_dir'] %}
{% set jenkins_master_hostname = pillar['system_hosts'][pillar['system_host_roles']['jenkins_master_role']['assigned_hosts'][0]]['hostname'] %}
{% set plugin_name = pillar['registered_content_items'][registered_content_item_id]['plugin_name'] %}

'{{ config_temp_dir }}/{{ pillar['registered_content_items'][registered_content_item_id]['item_base_name'] }}':
    file.managed:
        - source: '{{ get_registered_content_item_URI(registered_content_item_id) }}'
        - source_hash: '{{ get_registered_content_item_hash(registered_content_item_id) }}'
        - makedirs: True

install_jenkins_{{ registered_content_item_id }}:
    cmd.run:
        - name: 'java -jar {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:8080/ install-plugin {{ config_temp_dir }}/{{ pillar['registered_content_items'][registered_content_item_id]['item_base_name'] }} -restart'
        - unless: 'java -jar {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:8080/ list-plugins {{ plugin_name }} | grep {{ plugin_name }}'
        - require:

            # Prerequisite provided by the calling state:
            - cmd: '{{ registered_content_item_id }}_jenkins_plugin_installation_prerequisite'

            - file: '{{ config_temp_dir }}/{{ pillar['registered_content_items'][registered_content_item_id]['item_base_name'] }}'

{% endif %}

{% endmacro %}


