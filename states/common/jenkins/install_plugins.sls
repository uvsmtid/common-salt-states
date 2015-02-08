# Jenkins plugins

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS' ] %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Fedora' ] %}

include:
    - common.jenkins.master
    - common.jenkins.download_jenkins_cli_tool

{% if pillar['registered_content_items']['jenkins_cygwin_plugin']['enable_installation'] %}

{% set URI_prefix = pillar['registered_content_config']['URI_prefix'] %}

{% set config_temp_dir = pillar['posix_config_temp_dir'] %}
{% set jenkins_master_hostname = pillar['system_hosts'][pillar['system_host_roles']['jenkins_master_role']['assigned_hosts'][0]]['hostname'] %}
{% set plugin_name = pillar['registered_content_items']['jenkins_cygwin_plugin']['plugin_name'] %}

'{{ config_temp_dir }}/{{ pillar['registered_content_items']['jenkins_cygwin_plugin']['item_base_name'] }}':
    file.managed:
        - source: "{{ URI_prefix }}/{{ pillar['registered_content_items']['jenkins_cygwin_plugin']['item_parent_dir_path'] }}/{{ pillar['registered_content_items']['jenkins_cygwin_plugin']['item_base_name'] }}"
        - source_hash: {{ pillar['registered_content_items']['jenkins_cygwin_plugin']['item_content_hash'] }}
        - makedirs: True

install_jenkins_cygwin_plugin:
    cmd.run:
        - name: 'java -jar {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:8080/ install-plugin {{ config_temp_dir }}/{{ pillar['registered_content_items']['jenkins_cygwin_plugin']['item_base_name'] }} -restart'
        - unless: 'java -jar {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:8080/ list-plugins {{ plugin_name }} | grep {{ plugin_name }}'
        - require:
            - cmd: download_jenkins_cli_jar
            - file: '{{ config_temp_dir }}/{{ pillar['registered_content_items']['jenkins_cygwin_plugin']['item_base_name'] }}'

{% endif %}


{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

{% endif %}
# >>>
###############################################################################


