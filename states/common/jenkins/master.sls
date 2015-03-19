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
{% if grains['os'] in [ 'RedHat', 'CentOS' ] %} # OS

{% endif %} # OS
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Fedora' ] %} # OS

include:
    - common.ssh

{% if pillar['registered_content_items']['jenkins_yum_repository_rpm_verification_key']['enable_installation'] %} # enable_installation

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
        - source: '{{ get_registered_content_item_URI('jenkins_yum_repository_rpm_verification_key') }}'
        - source_hash: '{{ get_registered_content_item_hash('jenkins_yum_repository_rpm_verification_key') }}'
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
{% if pillar['registered_content_items']['jenkins_yum_repository_rpm_verification_key']['enable_installation'] %} # enable_installation
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

{% if False %} # Disabled
# The following state does not work at the moment due to a bug:
#   https://github.com/saltstack/salt/issues/11900

activate_jenkins_service:
    service.running:
        - name: jenkins
        - enable: True
        - require:
            - pkg: jenkins_rpm_package

{% else %} # Disabled

# This is a workaround described in the similar issue:
#   https://github.com/saltstack/salt/issues/8444

jenkins_service_enable:
    cmd.run:
        - name: "systemctl enable jenkins"
        - require:
            - pkg: jenkins_rpm_package
            - file: jenkins_credentials_configuration_file

# NOTE: This state should not be _restarted_, it should be _started_ because
#       it is assumed that it is actually started already. Otherwise,
#       CLI script won't be downloaded (Jenkins service is not ready to
#       provide download). If restart is required, use either orchestration
#       or stop it manually before applying this state.
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
{% if grains['os'] in [ 'Windows' ] %} # OS

{% endif %} # OS
# >>>
###############################################################################

{% endif %} # jenkins_master_role

