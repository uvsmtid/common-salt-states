# Configure Jenkins view based on XML configuration template.


{% macro view_config_include_item(view_name, view_config) %}

{% if view_config['enabled'] %}

# Keyword `include` should be provided in the calling Salt template.
#include:
    - common.jenkins.download_jenkins_cli_tool

{% endif %}

{% endmacro %}

{% set jenkins_http_port = pillar['system_features']['configure_jenkins']['jenkins_http_port'] %}

{% macro view_config_function(view_name, view_config) %}

{% if view_config['enabled'] %}

{% set jenkins_master_hostname = pillar['system_hosts'][pillar['system_host_roles']['jenkins_master_role']['assigned_hosts'][0]]['hostname'] %}

{% set URI_prefix = pillar['system_features']['deploy_central_control_directory']['URI_prefix'] %}

# Put view configuration:
'{{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins.view.config.{{ view_name }}.xml':
    file.managed:
        - source: 'salt://{{ view_config['view_config_data']['xml_config_template'] }}'
        - template: jinja
        - context:
            # The value of `view_config` is not a string, it is data.
            view_config: {{ view_config|json }}

            view_name: "{{ view_name }}"
            view_description: ""
            control_url: '{{ URI_prefix }}/{{ pillar['system_features']['deploy_central_control_directory']['control_dir_url_path'] }}'

# Make sure view configuration does not exist:
add_{{ view_name }}_view_configuration_to_jenkins:
    cmd.run:
        - name: "cat {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins.view.config.{{ view_name }}.xml | java -jar {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:{{ jenkins_http_port }}/ create-view {{ view_name }}"
        - unless: "java -jar {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:{{ jenkins_http_port }}/ get-view {{ view_name }}"
        - require:
            - cmd: download_jenkins_cli_jar
            - file: '{{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins.view.config.{{ view_name }}.xml'

# Update view configuration.
# The update won't happen (it will be the same) if view has just been created.
update_{{ view_name }}_view_configuration_to_jenkins:
    cmd.run:
        - name: "cat {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins.view.config.{{ view_name }}.xml | java -jar {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:{{ jenkins_http_port }}/ update-view {{ view_name }}"
{% if not pillar['system_features']['configure_jenkins']['rewrite_jenkins_configuration_for_views'] %}
        - unless: "java -jar {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:{{ jenkins_http_port }}/ get-view {{ view_name }}"
{% endif %}
        - require:
            - cmd: download_jenkins_cli_jar
            - file: '{{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins.view.config.{{ view_name }}.xml'
            - cmd: add_{{ view_name }}_view_configuration_to_jenkins

{% endif %} # view_config['enabled']

{% endmacro %}


