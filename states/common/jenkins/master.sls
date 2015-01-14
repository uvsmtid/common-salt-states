# Jenkins master

{% if grains['id'] in pillar['system_host_roles']['jenkins_master_role']['assigned_hosts'] %}

{% if grains['kernel'] == 'Linux' %}
{% set config_temp_dir = pillar['posix_config_temp_dir'] %}
{% endif %}
{% if grains['kernel'] == 'Windows' %}
{% set config_temp_dir = pillar['windows_config_temp_dir'] %}
{% endif %}

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
    - common.ssh

{% if pillar['registered_content_items']['jenkins_yum_repository_rpm_verification_key']['enable_installation'] %}

{% set URI_prefix = pillar['registered_content_config']['URI_prefix'] %}

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
        - source: '{{ URI_prefix }}/distrib/jenkins/jenkins-ci.org.key'
        - source_hash: {{ pillar['registered_content_items']['jenkins_yum_repository_rpm_verification_key']['item_content_hash'] }}
        - makedirs: True

import_jenkins_yum_repository_key:
    cmd.run:
        - name: 'rpm --import {{ config_temp_dir }}/jenkins/jenkins-ci.org.key'
        - require:
            - file: retrieve_jenkins_yum_repository_key

{% endif %}

jenkins_rpm_package:
    pkg.installed:
        - name: jenkins
# Set dependencies on special Jenkins repository only when it is enabled.
{% if pillar['registered_content_items']['jenkins_yum_repository_rpm_verification_key']['enable_installation'] %}
        - require:
            - file: /etc/yum.repos.d/jenkins.repo
            - cmd: import_jenkins_yum_repository_key
{% endif %}

{% if False %}
# The following state does not work at the moment due to a bug:
#   https://github.com/saltstack/salt/issues/11900

activate_jenkins_service:
    service.running:
        - name: jenkins
        - enable: True
        - require:
            - pkg: jenkins_rpm_package

{% else %}
# This is a workaround described in the similar issue:
#   https://github.com/saltstack/salt/issues/8444

jenkins_service_enable:
    cmd.run:
        - name: "systemctl enable jenkins"
        - require:
            - pkg: jenkins_rpm_package

jenkins_service_start:
    cmd.run:
        - name: "systemctl start jenkins"
        - require:
            - cmd: jenkins_service_enable

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

{% endif %}

