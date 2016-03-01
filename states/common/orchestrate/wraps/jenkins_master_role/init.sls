# Configure `jenkins_master_role` role.

{% if 'jenkins_master_role' in pillar['system_host_roles'] %}

{% if grains['id'] in pillar['system_host_roles']['jenkins_master_role']['assigned_hosts'] %}

include:

    - common.jenkins.master

    # Plugin for Jenkins:
    - common.jenkins.maven
    - common.jenkins.git
    - common.jenkins.pipeline
    - common.jenkins.cygwin
    - common.jenkins.infra

    - common.jenkins.node_configuration

    - common.jenkins.configure_jobs
    - common.jenkins.configure_views

    - common.jenkins.download_jenkins_cli_tool

{% endif %}

{% endif %}

