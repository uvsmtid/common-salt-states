# Jenkins nodes configurations.

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel5') %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel7') or grains['os_platform_type'].startswith('fc') %}

include:
    - common.jenkins.download_jenkins_cli_tool

{% set jenkins_http_port = pillar['system_features']['configure_jenkins']['jenkins_http_port'] %}

{% set jenkins_master_hostname = pillar['system_hosts'][pillar['system_host_roles']['jenkins_master_role']['assigned_hosts'][0]]['hostname'] %}

{% for slave_name in pillar['system_host_roles']['jenkins_slave_role']['assigned_hosts'] %}

{% set host_config = pillar['system_hosts'][slave_name] %}

{% set os_type = pillar['system_platforms'][host_config['os_platform']]['os_type'] %}

{% from 'common/libs/utils.lib.sls' import get_posix_salt_content_temp_dir with context %}

# Put node configuration:
'{{ get_posix_salt_content_temp_dir() }}/jenkins/jenkins.node.config.{{ slave_name }}.xml':
    file.managed:
        - source: salt://common/jenkins/jenkins.node.config.template.xml
        - template: jinja
        - context:
            minion_id: '{{ slave_name }}'
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
{% set account_conf = pillar['system_accounts'][ host_config['primary_user'] ] %}
{% if os_type == 'windows' %}
            jenkins_path: '{{ account_conf['windows_user_home_dir'] }}\jenkins'
{% else %}
            jenkins_path: '{{ account_conf['posix_user_home_dir'] }}/jenkins'
{% endif %}

# Make sure node configuration does not exist:
add_{{ slave_name }}_node_configuration_to_jenkins:
    cmd.run:
        - name: "cat {{ get_posix_salt_content_temp_dir() }}/jenkins/jenkins.node.config.{{ slave_name }}.xml | java -jar {{ get_posix_salt_content_temp_dir() }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:{{ jenkins_http_port }}/ create-node {{ slave_name }}"
        - unless: "java -jar {{ get_posix_salt_content_temp_dir() }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:{{ jenkins_http_port }}/ get-node {{ slave_name }}"
        - require:
            - cmd: download_jenkins_cli_jar
            - file: '{{ get_posix_salt_content_temp_dir() }}/jenkins/jenkins.node.config.{{ slave_name }}.xml'

# Update node configuration.
# The update won't happen (it will be the same) if node has just been created.
update_{{ slave_name }}_node_configuration_to_jenkins:
    cmd.run:
        - name: "cat {{ get_posix_salt_content_temp_dir() }}/jenkins/jenkins.node.config.{{ slave_name }}.xml | java -jar {{ get_posix_salt_content_temp_dir() }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:{{ jenkins_http_port }}/ update-node {{ slave_name }}"
{% if not pillar['system_features']['configure_jenkins']['rewrite_jenkins_configuration_for_nodes'] %}
        - unless: "java -jar {{ get_posix_salt_content_temp_dir() }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:{{ jenkins_http_port }}/ get-node {{ slave_name }}"
{% endif %}
        - require:
            - cmd: download_jenkins_cli_jar
            - file: '{{ get_posix_salt_content_temp_dir() }}/jenkins/jenkins.node.config.{{ slave_name }}.xml'
            - cmd: add_{{ slave_name }}_node_configuration_to_jenkins

# Reconnect slave node:
{% if pillar['system_features']['configure_jenkins']['make_sure_nodes_are_connected'] %}
reconnect_{{ slave_name }}_node_with_jenkins:
    cmd.run:
        - name: 'java -jar {{ get_posix_salt_content_temp_dir() }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:{{ jenkins_http_port }}/ connect-node {{ slave_name }} -f'
        - require:
            - cmd: download_jenkins_cli_jar
            - cmd: add_{{ slave_name }}_node_configuration_to_jenkins
{% endif %}

{% endfor %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

{% endif %}
# >>>
###############################################################################


