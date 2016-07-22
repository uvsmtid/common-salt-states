
###############################################################################
#

include:

{% for sub_item in [
        'localhost_role'
        ,
        'primary_console_role'
        ,
        'controller_role'
        ,
        'router_role'
        ,
        'hostname_resolver_role'
        ,
        'time_server_role'
        ,
        'hypervisor_role'
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
        'sonar_qube_role'
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

