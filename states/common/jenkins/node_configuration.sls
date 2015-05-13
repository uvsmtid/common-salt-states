# Jenkins nodes configurations.

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
    - common.jenkins.download_jenkins_cli_tool

{% set jenkins_master_hostname = pillar['system_hosts'][pillar['system_host_roles']['jenkins-master-role']['assigned_hosts'][0]]['hostname'] %}
{% set jenkins_linux_slaves = pillar['system_host_roles']['jenkins-linux-slave-role']['assigned_hosts'] %}
{% set jenkins_windows_slaves = pillar['system_host_roles']['jenkins-windows-slave-role']['assigned_hosts'] %}

{% for slave in jenkins_linux_slaves + jenkins_windows_slaves %}

{% set host_config = pillar['system_hosts'][slave] %}

# Put node configuration:
'{{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins.node.config.{{ host_config['hostname'] }}.xml':
    file.managed:
        - source: salt://common/jenkins/jenkins.node.config.template.xml
        - template: jinja
        - context:
            minion_id: '{{ slave }}'
            # NOTE: `jenkins_path` should depend on the platform (Windows or Linix)
            #       because Java running Jenkins creates directories according
            #       to the platform.
            #
            #       Note also that the problem of cygwin path conversion was
            #       supposed to be fixed by "Cygpath Plugin", but it doesn't
            #       seem to be fixed (and what was fixed by this pluggin
            #       then?).
            #       For example, slave Windows node still wrongly creates
            #       directory C:\home\neldev\jenkins when /home/neldev/jenkins
            #       is specified.
            #       There is even related bug in Jenkins bug tracker which
            #       does the same workaround (specyfing Windows-style path):
            #         https://issues.jenkins-ci.org/browse/JENKINS-21770
{% if host_config['os_type'] == 'windows' %}
            jenkins_path: '{{ host_config['primary_user']['windows_user_home_dir'] }}\jenkins'
{% else %}
            jenkins_path: '{{ host_config['primary_user']['posix_user_home_dir'] }}/jenkins'
{% endif %}

# Make sure node configuration does not exist:
add_{{ host_config['hostname'] }}_node_configuration_to_jenkins:
    cmd.run:
        - name: "cat {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins.node.config.{{ host_config['hostname'] }}.xml | java -jar {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:8080/ create-node {{ host_config['hostname'] }}"
        - unless: "java -jar {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:8080/ get-node {{ host_config['hostname'] }}"
        - require:
            - cmd: download_jenkins_cli_jar
            - file: '{{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins.node.config.{{ host_config['hostname'] }}.xml'

# Update node configuration.
# The update won't happen (it will be the same) if node has just been created.
update_{{ host_config['hostname'] }}_node_configuration_to_jenkins:
    cmd.run:
        - name: "cat {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins.node.config.{{ host_config['hostname'] }}.xml | java -jar {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:8080/ update-node {{ host_config['hostname'] }}"
{% if not pillar['system_features']['configure_jenkins']['rewrite_jenkins_configuration_for_nodes'] %}
        - unless: "java -jar {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:8080/ get-node {{ host_config['hostname'] }}"
{% endif %}
        - require:
            - cmd: download_jenkins_cli_jar
            - file: '{{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins.node.config.{{ host_config['hostname'] }}.xml'
            - cmd: add_{{ host_config['hostname'] }}_node_configuration_to_jenkins

# Reconnect slave node:
{% if pillar['system_features']['configure_jenkins']['make_sure_nodes_are_connected'] %}
reconnect_{{ host_config['hostname'] }}_node_with_jenkins:
    cmd.run:
        - name: 'java -jar {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:8080/ connect-node {{ host_config['hostname'] }} -f'
        - require:
            - cmd: download_jenkins_cli_jar
            - cmd: add_{{ host_config['hostname'] }}_node_configuration_to_jenkins
{% endif %}

{% endfor %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

{% endif %}
# >>>
###############################################################################


