# Macro for installing Jenkins plugin.

{% from 'common/jenkins/wait_for_online_master.sls' import wait_for_online_jenkins_master_macro with context %}

{% macro jenkins_plugin_installation_macros(registered_content_item_id, unique_suffix) %}

{% if pillar['system_resources'][registered_content_item_id]['enable_installation'] %}

{% set jenkins_http_port = pillar['system_features']['configure_jenkins']['jenkins_http_port'] %}

{% set resources_macro_lib = 'common/resource_symlinks/resources_macro_lib.sls' %}
{% from resources_macro_lib import get_registered_content_item_URI with context %}
{% from resources_macro_lib import get_registered_content_item_hash with context %}

{% from 'common/libs/utils.lib.sls' import get_salt_content_temp_dir with context %}
{% from 'common/libs/utils.lib.sls' import get_posix_salt_content_temp_dir with context %}

{% set jenkins_master_hostname = pillar['system_hosts'][pillar['system_host_roles']['jenkins_master_role']['assigned_hosts'][0]]['hostname'] %}
{% set plugin_name = pillar['system_resources'][registered_content_item_id]['plugin_name'] %}

'{{ get_salt_content_temp_dir() }}/{{ pillar['system_resources'][registered_content_item_id]['item_base_name'] }}_{{ unique_suffix }}':
    file.managed:
        - name: '{{ get_salt_content_temp_dir() }}/{{ pillar['system_resources'][registered_content_item_id]['item_base_name'] }}'
        - source: {{ get_registered_content_item_URI(registered_content_item_id) }}
        - source_hash: {{ get_registered_content_item_hash(registered_content_item_id) }}
        - makedirs: True

install_jenkins_{{ registered_content_item_id }}_{{ unique_suffix }}:
    cmd.run:
        - name: 'java -jar {{ get_posix_salt_content_temp_dir() }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:{{ jenkins_http_port }}/ install-plugin {{ get_salt_content_temp_dir() }}/{{ pillar['system_resources'][registered_content_item_id]['item_base_name'] }} -restart'
        - unless: 'java -jar {{ get_posix_salt_content_temp_dir() }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:{{ jenkins_http_port }}/ list-plugins {{ plugin_name }} | grep {{ plugin_name }}'
        - require:

            # Prerequisite provided by the calling state:
            - cmd: '{{ registered_content_item_id }}_jenkins_plugin_installation_prerequisite_{{ unique_suffix }}'

            - file: '{{ get_salt_content_temp_dir() }}/{{ pillar['system_resources'][registered_content_item_id]['item_base_name'] }}_{{ unique_suffix }}'

# Wait until Jenkins master restarts.
{% set unique_item_id = registered_content_item_id + unique_suffix %}
{{ wait_for_online_jenkins_master_macro(unique_item_id) }}

# Run a command with dependency on completion of waiting for Jenkins master.
dummy_jenkins_plugin_installation_complete_{{ unique_item_id }}:
    cmd.run:
        - name: 'echo jenkins plugin installation complete: {{ registered_content_item_id }}'
        - require:
            - cmd: wait_for_online_jenkins_master_{{ unique_item_id }}

{% endif %}

{% endmacro %}


