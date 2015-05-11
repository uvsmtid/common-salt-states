
###############################################################################
#

{% set master_minion_id = salt['config.get']('this_system_keys:master_minion_id') %}
{% set profile = salt['config.get']('this_system_keys:profile') %}

system_host_roles:

    # Primary console is the machine which user/developer
    # interacts with to control the rest of the system.
    # It should normally be a barebone machine and may
    # share roles like `controller_role`, `hypervisor_role`, etc.
    # For example, it should normally provide graphical environment
    # (to use browser to access Jenkins), it may provide
    # X server to run remote apps with graphical interface.
    primary_console_role:
        assigned_hosts:
            - {{ master_minion_id }}

    controller_role:
        assigned_hosts:
            - {{ master_minion_id }}

    router_role:
        assigned_hosts:
            - {{ master_minion_id }}

    resolver_role:
        assigned_hosts:
            - {{ master_minion_id }}

    hypervisor_role:
        assigned_hosts:
            - {{ master_minion_id }}

    depository_role:
        assigned_hosts:
            - {{ master_minion_id }}

    maven_build_server_role:
        assigned_hosts:
            - {{ master_minion_id }}

    # Jenkins master is always linux.
    jenkins_master_role:
        assigned_hosts:
            - {{ master_minion_id }}

    jenkins_linux_slave_role:
        assigned_hosts:
            - {{ master_minion_id }}

    jenkins_windows_slave_role:
        assigned_hosts: []

    # Sonatype Nexus is used as Maven Repository Manager.
    maven_repository_upstream_manager_role:
        # NOTE: These should be hosts different from `downstream`.
        assigned_hosts: []

    maven_repository_downstream_manager_role:
        # NOTE: These should be hosts different from `upstream`.
        assigned_hosts:
            - {{ master_minion_id }}

    openstack-client-role:
        assigned_hosts:
            - {{ master_minion_id }}

###############################################################################
# EOF
###############################################################################

