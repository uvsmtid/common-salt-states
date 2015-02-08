# Maven configuration for Jenkins.

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

include:
    - common.jenkins.master
    - common.jenkins.download_jenkins_cli_tool

{% if pillar['registered_content_items']['jenkins_maven_project_plugin']['enable_installation'] %}

{% set URI_prefix = pillar['registered_content_config']['URI_prefix'] %}

{% set config_temp_dir = pillar['posix_config_temp_dir'] %}
{% set jenkins_master_hostname = pillar['system_hosts'][pillar['system_host_roles']['jenkins_master_role']['assigned_hosts'][0]]['hostname'] %}
{% set plugin_name = pillar['registered_content_items']['jenkins_maven_project_plugin']['plugin_name'] %}

'{{ config_temp_dir }}/{{ pillar['registered_content_items']['jenkins_maven_project_plugin']['item_base_name'] }}':
    file.managed:
        - source: "{{ URI_prefix }}/{{ pillar['registered_content_items']['jenkins_maven_project_plugin']['item_parent_dir_path'] }}/{{ pillar['registered_content_items']['jenkins_maven_project_plugin']['item_base_name'] }}"
        - source_hash: {{ pillar['registered_content_items']['jenkins_maven_project_plugin']['item_content_hash'] }}
        - makedirs: True

install_jenkins_maven_project_plugin:
    cmd.run:
        - name: 'java -jar {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:8080/ install-plugin {{ config_temp_dir }}/{{ pillar['registered_content_items']['jenkins_maven_project_plugin']['item_base_name'] }} -restart'
        - unless: 'java -jar {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:8080/ list-plugins {{ plugin_name }} | grep {{ plugin_name }}'
        - require:
            - cmd: download_jenkins_cli_jar
            - file: '{{ config_temp_dir }}/{{ pillar['registered_content_items']['jenkins_maven_project_plugin']['item_base_name'] }}'

{% endif %}

maven_jenkins_configuration_file:
    file.managed:
        - name: '{{ pillar['system_features']['configure_jenkins']['jenkins_root_dir'] }}/hudson.tasks.Maven.xml'
        - source: 'salt://common/jenkins/maven/hudson.tasks.Maven.xml'
        - mode: 644
        - template: jinja
        - require:
            - pkg: jenkins_rpm_package
            - cmd: install_jenkins_maven_project_plugin

extend:
    jenkins_service_enable:
        cmd:
            - require:
                - file: maven_jenkins_configuration_file

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

{% endif %}
# >>>
###############################################################################


