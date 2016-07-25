
###############################################################################
#

include:

{% for sub_item in [
        'localhost_role'
        ,
        'salt_master_role'
        ,
        'salt_minion_role'
        ,
        'primary_console_role'
        ,
        'network_router_role'
        ,
        'hostname_resolver_role'
        ,
        'time_server_role'
        ,
        'virtual_machine_hypervisor_role'
        ,
        'depository_role'
        ,
        'local_yum_mirrors_role'
        ,
        'maven_build_server_role'
        ,
        'jenkins_master_role'
        ,
        'jenkins_slave_role'
        ,
        'sonarqube_server_role'
        ,
        'maven_repository_upstream_manager_role'
        ,
        'maven_repository_downstream_manager_role'
        ,
        'openstack_client_role'
        ,
        'wildfly_node_1_role'
        ,
        'wildfly_node_2_role'
        ,
        'vagrant_box_publisher_role'
    ]
%}
    - {{ this_pillar }}.{{ sub_item }}:
        defaults:
            this_pillar: {{ this_pillar }}.{{ sub_item }}
            profile_root: {{ profile_root }}

{% endfor %}

###############################################################################
# EOF
###############################################################################

