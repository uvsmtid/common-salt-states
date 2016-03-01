# Configure `jenkins_slave_role` role.

{% if 'jenkins_slave_role' in pillar['system_host_roles'] %}

{% if grains['id'] in pillar['system_host_roles']['jenkins_slave_role']['assigned_hosts'] %}

include:

    - common.jenkins.slave

    # Deploy environment sources.
    - common.environment_source_code.prepare_environment_source_directories
    - common.environment_source_code.deploy_environment_sources

{% endif %}

{% endif %}

