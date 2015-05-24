
###############################################################################
#

{% set master_minion_id = salt['config.get']('this_system_keys:master_minion_id') %}
{% set profile_name = salt['config.get']('this_system_keys:profile_name') %}

system_host_roles:

    # Primary console is the machine which user/developer
    # interacts with to control the rest of the system.
    # It should normally be a barebone machine and may
    # share roles like `controller_role`, `hypervisor_role`, etc.
    # For example, it should normally provide graphical environment
    # (to use browser to access Jenkins), it may provide
    # X server to run remote apps with graphical interface.
    primary_console_role:
        hostname: primary-console-role-host
        assigned_hosts:
            - {{ master_minion_id }}

    controller_role:
        hostname: controller-role-host
        assigned_hosts:
            - {{ master_minion_id }}

    router_role:
        hostname: router-role-host
        assigned_hosts:
            - {{ master_minion_id }}

    resolver_role:
        hostname: resolver-role-host
        assigned_hosts:
            - {{ master_minion_id }}

    hypervisor_role:
        hostname: hypervisor-role-host
        assigned_hosts:
            - {{ master_minion_id }}

    depository_role:
        hostname: depository-role-host
        assigned_hosts:
            - {{ master_minion_id }}

    maven_build_server_role:
        hostname: maven-build-server-role-host
        assigned_hosts:
            - {{ master_minion_id }}
            - rhel7_minion

    # Jenkins master is always linux.
    jenkins_master_role:
        hostname: jenkins-master-role-host
        assigned_hosts:
            - {{ master_minion_id }}

    jenkins_slave_role:
        hostname: jenkins-slave-role-host
        assigned_hosts:
            - {{ master_minion_id }}
            - rhel5_minion
            - rhel7_minion

    # Sonatype Nexus is used as Maven Repository Manager.
    maven_repository_upstream_manager_role:
        hostname: maven-repository-upstream-manager-role-host
        # NOTE: These should be hosts different from `downstream`.
        assigned_hosts: []

    maven_repository_downstream_manager_role:
        hostname: maven-repository-downstream-manager-role-host
        # NOTE: These should be hosts different from `upstream`.
        assigned_hosts:
            - {{ master_minion_id }}

    openstack_client_role:
        hostname: openstack-client-role-host
        assigned_hosts:
            - {{ master_minion_id }}

###############################################################################
# EOF
###############################################################################

