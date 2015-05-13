
###############################################################################
#

{% set master_minion_id = salt['config.get']('this_system_keys:master_minion_id') %}
{% set profile = salt['config.get']('this_system_keys:profile') %}

system_host_roles:

    # Primary console is the machine which user/developer
    # interacts with to control the rest of the system.
    # It should normally be a barebone machine and may
    # share roles like `controller-role`, `hypervisor-role`, etc.
    # For example, it should normally provide graphical environment
    # (to use browser to access Jenkins), it may provide
    # X server to run remote apps with graphical interface.
    primary-console-role:
        assigned_hosts:
            - {{ master_minion_id }}

    controller-role:
        assigned_hosts:
            - {{ master_minion_id }}

    router-role:
        assigned_hosts:
            - {{ master_minion_id }}

    resolver-role:
        assigned_hosts:
            - {{ master_minion_id }}

    hypervisor-role:
        assigned_hosts:
            - {{ master_minion_id }}

    depository-role:
        assigned_hosts:
            - {{ master_minion_id }}

    maven-build-server-role:
        assigned_hosts:
            - {{ master_minion_id }}

    # Jenkins master is always linux.
    jenkins-master-role:
        assigned_hosts:
            - {{ master_minion_id }}

    jenkins-linux-slave-role:
        assigned_hosts:
            - {{ master_minion_id }}

    jenkins-windows-slave-role:
        assigned_hosts: []

    # Sonatype Nexus is used as Maven Repository Manager.
    maven-repository-upstream-manager-role:
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

