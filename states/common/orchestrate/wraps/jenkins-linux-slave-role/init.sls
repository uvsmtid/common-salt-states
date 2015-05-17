# Configure `jenkins-linux-slave-role` role.

{% if grains['id'] in pillar['system_host_roles']['jenkins-linux-slave-role']['assigned_hosts'] %}

include:

    # Deploy environment sources.
    - common.environment_source_code.prepare_environment_source_directories
    - common.environment_source_code.deploy_environment_sources

{% endif %}

