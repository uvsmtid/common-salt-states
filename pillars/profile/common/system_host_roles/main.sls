
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set master_minion_id = props['master_minion_id'] %}
{% set profile_name = props['profile_name'] %}

# Macro to filter list of assigned minions by `enabled_minion_hosts`.
{% macro filter_assigned_hosts_by_enabled_minion_hosts(assigned_minion_list) %}
            [
{% for selected_minion_id in assigned_minion_list %}
{% if selected_minion_id in props['enabled_minion_hosts'].keys() %}
                {{ selected_minion_id }}
{% if not loop.last %}
                ,
{% endif %}
{% endif %}
{% endfor %}
            ]
{% endmacro %}

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
            {{ filter_assigned_hosts_by_enabled_minion_hosts([
                    master_minion_id
                ])
            }}

    controller_role:
        hostname: controller-role-host
        assigned_hosts:
            {{ filter_assigned_hosts_by_enabled_minion_hosts([
                    master_minion_id
                ])
            }}

    router_role:
        hostname: router-role-host
        assigned_hosts:
            {{ filter_assigned_hosts_by_enabled_minion_hosts([
                    master_minion_id
                ])
            }}

    resolver_role:
        hostname: resolver-role-host
        assigned_hosts:
            {{ filter_assigned_hosts_by_enabled_minion_hosts([
                    master_minion_id
                ])
            }}

    hypervisor_role:
        hostname: hypervisor-role-host
        assigned_hosts:
            {{ filter_assigned_hosts_by_enabled_minion_hosts([
                    master_minion_id
                ])
            }}

    depository_role:
        hostname: depository-role-host
        assigned_hosts:
            {{ filter_assigned_hosts_by_enabled_minion_hosts([
                    master_minion_id
                ])
            }}

    maven_build_server_role:
        hostname: maven-build-server-role-host
        assigned_hosts:
            {{ filter_assigned_hosts_by_enabled_minion_hosts([
                    master_minion_id
                    ,
                    'rhel7_minion'
                ])
            }}

    # Jenkins master is always linux.
    jenkins_master_role:
        hostname: jenkins-master-role-host
        assigned_hosts:
            {{ filter_assigned_hosts_by_enabled_minion_hosts([
                    master_minion_id
                ])
            }}

    jenkins_slave_role:
        hostname: jenkins-slave-role-host
        assigned_hosts:
            {{ filter_assigned_hosts_by_enabled_minion_hosts([
                    master_minion_id
                    ,
                    'rhel5_minion'
                    ,
                    'rhel7_minion'
                ])
            }}

    # Sonatype Nexus is used as Maven Repository Manager.
    maven_repository_upstream_manager_role:
        hostname: maven-repository-upstream-manager-role-host
        # NOTE: These should be hosts different from `downstream`.
        assigned_hosts:
            {{ filter_assigned_hosts_by_enabled_minion_hosts([
                ])
            }}

    maven_repository_downstream_manager_role:
        hostname: maven-repository-downstream-manager-role-host
        # NOTE: These should be hosts different from `upstream`.
        assigned_hosts:
            {{ filter_assigned_hosts_by_enabled_minion_hosts([
                    master_minion_id
                ])
            }}

    openstack_client_role:
        hostname: openstack-client-role-host
        assigned_hosts:
            {{ filter_assigned_hosts_by_enabled_minion_hosts([
                    master_minion_id
                ])
            }}

###############################################################################
# EOF
###############################################################################

