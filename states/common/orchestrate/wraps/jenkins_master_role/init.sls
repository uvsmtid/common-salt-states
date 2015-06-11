# Configure `jenkins_master_role` role.

{% if grains['id'] in pillar['system_host_roles']['jenkins_master_role']['assigned_hosts'] %}

include:

    - common.jenkins.master
    - common.jenkins.maven
    - common.jenkins.git
    - common.jenkins.layout

    - common.jenkins.cygwin

    - common.jenkins.node_configuration

    - common.jenkins.configure_jobs

    - common.jenkins.download_jenkins_cli_tool

{% endif %}

