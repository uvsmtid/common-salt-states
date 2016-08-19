#!/bin/sh

{% set jenkins_master_hostname = pillar['system_hosts'][pillar['system_host_roles']['jenkins_master_role']['assigned_hosts'][0]]['hostname'] %}
{% set jenkins_http_port = pillar['system_features']['configure_jenkins']['jenkins_http_port'] %}

{% from 'common/libs/utils.lib.sls' import get_posix_salt_content_temp_dir with context %}

# Loop through all existing jobs in Jenkins.
for EXISTING_JOB_NAME in \
    $( java -jar {{ get_posix_salt_content_temp_dir() }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:{{ jenkins_http_port }}/ list-jobs All )

do
    # If existing job in Jenkins cannot be found in a string containing all
    # jobs configured in pilllars, it should be disabled.
    if ! ( echo "{{ pillar['system_tasks']['jenkins_tasks'].keys()|join(' ') }}" | grep -F "${EXISTING_JOB_NAME}" )
    then
        java -jar {{ get_posix_salt_content_temp_dir() }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:{{ jenkins_http_port }}/ disable-job "${EXISTING_JOB_NAME}"
    fi
done

