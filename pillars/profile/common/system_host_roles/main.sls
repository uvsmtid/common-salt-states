
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set master_minion_id = props['master_minion_id'] %}
{% set profile_name = props['profile_name'] %}

{% set pillars_macro_lib = 'lib/pillars_macro_lib.sls' %}
{% from pillars_macro_lib import filter_assigned_hosts_by_minion_hosts_enabled_in_properties with context %}

system_host_roles:

    # Special case: host role which poings to localhost.
    localhost_role:
        hostname: localhost-host-role-host
        assigned_hosts:
            {{ filter_assigned_hosts_by_minion_hosts_enabled_in_properties([
                    'localhost_host'
                ], props)
            }}

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
            {{ filter_assigned_hosts_by_minion_hosts_enabled_in_properties([
                    master_minion_id
                ], props)
            }}

    controller_role:
        hostname: controller-role-host
        assigned_hosts:
            {{ filter_assigned_hosts_by_minion_hosts_enabled_in_properties([
                    master_minion_id
                ], props)
            }}

    router_role:
        hostname: router-role-host
        assigned_hosts:
            {{ filter_assigned_hosts_by_minion_hosts_enabled_in_properties([
                    master_minion_id
                ], props)
            }}

    resolver_role:
        hostname: resolver-role-host
        assigned_hosts:
            {{ filter_assigned_hosts_by_minion_hosts_enabled_in_properties([
                    master_minion_id
                ], props)
            }}

    time_server_role:
        hostname: time-server-role-host
        assigned_hosts:
            {{ filter_assigned_hosts_by_minion_hosts_enabled_in_properties([
                    master_minion_id
                ], props)
            }}

    hypervisor_role:
        hostname: hypervisor-role-host
        assigned_hosts:
            {{ filter_assigned_hosts_by_minion_hosts_enabled_in_properties([
                    master_minion_id
                ], props)
            }}

    depository_role:
        hostname: depository-role-host
        assigned_hosts:
            {{ filter_assigned_hosts_by_minion_hosts_enabled_in_properties([
                    master_minion_id
                ], props)
            }}

    local_yum_mirrors_role:
        hostname: local-yum-mirrors-role-host
        assigned_hosts:
            # NOTE: We use single (central) host for repositories by default.
            #       The content size is big and it makes sense to centralize it.
            {{ filter_assigned_hosts_by_minion_hosts_enabled_in_properties([
                    'jenkins'
                ], props)
            }}

    maven_build_server_role:
        hostname: maven-build-server-role-host
        assigned_hosts:
            {{ filter_assigned_hosts_by_minion_hosts_enabled_in_properties([
                    master_minion_id
                    ,
                    'rhel7_minion'
                ], props)
            }}

    # Jenkins master is always linux.
    jenkins_master_role:
        hostname: jenkins-master-role-host
        assigned_hosts:
            # NOTE: Add `master_minion_id` minion to install and configure
            #       Jenkins on master minion Salt node.
            #       It is disabled by default.
            {{ filter_assigned_hosts_by_minion_hosts_enabled_in_properties([
                    master_minion_id
                ], props)
            }}

    jenkins_slave_role:
        hostname: jenkins-slave-role-host
        assigned_hosts:
            {{ filter_assigned_hosts_by_minion_hosts_enabled_in_properties([
                    'localhost_host'
                    ,
                    master_minion_id
                    ,
                    'rhel5_minion'
                    ,
                    'rhel7_minion'
                ], props)
            }}

    # SonarQube role.
    sonar_qube_role:
        hostname: sonar-qube-role-host
        assigned_hosts:
            # NOTE: Add `master_minion_id` minion to install and configure
            #       SonarQube on master minion Salt node.
            #       It is disabled by default.
            {{ filter_assigned_hosts_by_minion_hosts_enabled_in_properties([
                    master_minion_id
                ], props)
            }}

    # Sonatype Nexus is used as Maven Repository Manager.
    maven_repository_upstream_manager_role:
        hostname: maven-repository-upstream-manager-role-host
        # NOTE: These should be hosts different from `downstream`.
        assigned_hosts:
            {{ filter_assigned_hosts_by_minion_hosts_enabled_in_properties([
                ], props)
            }}

    maven_repository_downstream_manager_role:
        hostname: maven-repository-downstream-manager-role-host
        # NOTE: These should be hosts different from `upstream`.
        assigned_hosts:
            {{ filter_assigned_hosts_by_minion_hosts_enabled_in_properties([
                    master_minion_id
                ], props)
            }}

    openstack_client_role:
        hostname: openstack-client-role-host
        assigned_hosts:
            {{ filter_assigned_hosts_by_minion_hosts_enabled_in_properties([
                    master_minion_id
                ], props)
            }}

    wildfly_node_1_role:
        hostname: wildfly-node-role
        assigned_hosts:
            {{ filter_assigned_hosts_by_minion_hosts_enabled_in_properties([
                    master_minion_id
                ], props)
            }}

    wildfly_node_2_role:
        hostname: wildfly-node-role
        assigned_hosts:
            {{ filter_assigned_hosts_by_minion_hosts_enabled_in_properties([
                    master_minion_id
                ], props)
            }}

###############################################################################
# EOF
###############################################################################

