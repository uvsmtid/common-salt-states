# Salt top states file

# Master configuration file should contain similar data structure:
#     this_system_keys:
#         project_name: project_name
#         profile_name: profile_name
#
# See also:
#   https://github.com/saltstack/salt/issues/12916
{% set project_name = salt['config.get']('this_system_keys:project_name') %}
{% set profile_name = salt['config.get']('this_system_keys:profile_name') %}

include:

{% if 'common' == project_name %}

    # roles

        # TODO:
        #- primary_console_role

        - common.orchestrate.wraps.controller_role

        # TODO:
        #- common.orchestrate.wraps.router_role
        #- common.orchestrate.wraps.resolver_role

        - common.orchestrate.wraps.hypervisor_role

        - common.orchestrate.wraps.depository_role

        - common.orchestrate.wraps.maven_build_server_role

        - common.orchestrate.wraps.jenkins_master_role
        - common.orchestrate.wraps.jenkins_slave_role

        # This wrap handles both:
        # - maven_repository_upstream_manager_role
        # - maven_repository_downstream_manager_role
        - common.orchestrate.wraps.maven_repository_manager_role

        - common.orchestrate.wraps.openstack_client_role

    # main
        - common.orchestrate.wraps.main

{% endif %}

###############################################################################
# EOF
###############################################################################

