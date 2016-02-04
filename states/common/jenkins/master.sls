# Jenkins master

{% if grains['id'] in pillar['system_host_roles']['jenkins_master_role']['assigned_hosts'] %} # jenkins_master_role

{% if grains['kernel'] == 'Linux' %} # Linux
{% set config_temp_dir = pillar['posix_config_temp_dir'] %}
{% endif %} # Linux
{% if grains['kernel'] == 'Windows' %} # Windows
{% set config_temp_dir = pillar['windows_config_temp_dir'] %}
{% endif %} # Windows

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel5') %} # OS

{% endif %} # OS
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel7') or grains['os_platform_type'].startswith('fc') %} # OS

include:
    - common.ssh

{% if pillar['system_resources']['jenkins_yum_repository_rpm_verification_key']['enable_installation'] %} # enable_installation

{% set resources_macro_lib = 'common/resource_symlinks/resources_macro_lib.sls' %}
{% from resources_macro_lib import get_registered_content_item_URI with context %}
{% from resources_macro_lib import get_registered_content_item_hash with context %}

/etc/yum.repos.d/jenkins.repo:
    file.managed:
        - source: salt://common/jenkins/jenkins.repo
        - user: root
        - group: root
        - mode: 644
        - template: jinja

retrieve_jenkins_yum_repository_key:
    file.managed:
        - name: '{{ config_temp_dir }}/jenkins/jenkins-ci.org.key'
        - source: {{ get_registered_content_item_URI('jenkins_yum_repository_rpm_verification_key') }}
        - source_hash: {{ get_registered_content_item_hash('jenkins_yum_repository_rpm_verification_key') }}
        - makedirs: True

import_jenkins_yum_repository_key:
    cmd.run:
        - name: 'rpm --import {{ config_temp_dir }}/jenkins/jenkins-ci.org.key'
        - require:
            - file: retrieve_jenkins_yum_repository_key

{% endif %} # enable_installation

jenkins_rpm_package:
    pkg.installed:
        - name: jenkins
        - aggregate: True
# Set dependencies on special Jenkins repository only when it is enabled.
{% if pillar['system_resources']['jenkins_yum_repository_rpm_verification_key']['enable_installation'] %} # enable_installation
        - require:
            - file: /etc/yum.repos.d/jenkins.repo
            - cmd: import_jenkins_yum_repository_key
{% endif %} # enable_installation

jenkins_credentials_configuration_file:
    file.managed:
        - name: '{{ pillar['system_features']['configure_jenkins']['jenkins_root_dir'] }}/credentials.xml'
        - source: 'salt://common/jenkins/credentials.xml.sls'
        - template: jinja
        - makedirs: False
        - require:
            - pkg: jenkins_rpm_package

jenkins_configuration_file:
    file.managed:
        - name: /etc/sysconfig/jenkins
        - source: salt://common/jenkins/jenkins.conf
        - template: jinja
        - makedirs: False

# TODO: This is supposed to be refactored to be done through configuration.
# Deploy configuration files for plugins which need them (in advance).
{% for plugin_config_file in [
        'sidebar-link.xml',
        'jenkins.advancedqueue.PriorityConfiguration.xml',
        'jenkins.advancedqueue.PrioritySorterConfiguration.xml',
        'hudson.plugins.sonar.MsBuildSQRunnerInstallation.xml',                
        'hudson.plugins.sonar.SonarPublisher.xml',                             
        'hudson.plugins.sonar.SonarRunnerInstallation.xml',
    ]
%}

jenkins_plugin_config_file_{{ plugin_config_file }}:
    file.managed:
        - name: '{{ pillar['system_features']['configure_jenkins']['jenkins_root_dir'] }}/{{ plugin_config_file }}'
        - source: salt://common/jenkins/plugin_configs/{{ plugin_config_file }}
        - template: jinja

{% endfor %}

{% if False %} # Disabled
# The following state does not work at the moment due to a bug:
#   https://github.com/saltstack/salt/issues/11900

activate_jenkins_service:
    service.running:
        - name: jenkins
        - enable: True
        - require:
            - pkg: jenkins_rpm_package
            - file: jenkins_credentials_configuration_file
            - file: jenkins_configuration_file

{% else %} # Disabled

# This is a workaround described in the similar issue:
#   https://github.com/saltstack/salt/issues/8444

jenkins_service_enable:
    cmd.run:
        - name: "systemctl enable jenkins"
        - require:
            - pkg: jenkins_rpm_package
            - file: jenkins_credentials_configuration_file
            - file: jenkins_configuration_file

# NOTE: In order to wait for end of Jenkins restart, see/use:
#       states/common/jenkins/download_jenkins_cli_tool.sls
# NOTE: We do not restart Jenkins because this state may be part
#       of the `highstate` ruy by Jenkins job. Instead, we only
#       require Jenkins to be started.
jenkins_service_start:
    cmd.run:
        - name: "systemctl start jenkins"
        - require:
            - cmd: jenkins_service_enable

{% endif %} # Disabled


{% endif %} # OS
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %} # OS

{% endif %} # OS
# >>>
###############################################################################

{% endif %} # jenkins_master_role

