# Salt main states file

{% set project_name = pillar['project_name'] %}
{% set profile_name = pillar['profile_name'] %}

include:

{% if 'common' == project_name %}

    # roles

        - common.orchestrate.wraps.primary_console_role

        - common.orchestrate.wraps.salt_master_role
        - common.orchestrate.wraps.salt_minion_role

        - common.orchestrate.wraps.network_router_role
        - common.orchestrate.wraps.hostname_resolver_role

        - common.orchestrate.wraps.time_server_role

        - common.orchestrate.wraps.virtual_machine_hypervisor_role

        - common.orchestrate.wraps.depository_role

        - common.orchestrate.wraps.local_yum_mirrors_role

        - common.orchestrate.wraps.maven_build_server_role

        - common.orchestrate.wraps.jenkins_master_role
        - common.orchestrate.wraps.jenkins_slave_role

        - common.orchestrate.wraps.sonarqube_server_role

        # This wrap handles both:
        # - maven_repository_upstream_manager_role
        # - maven_repository_downstream_manager_role
        - common.orchestrate.wraps.maven_repository_manager_role

        - common.orchestrate.wraps.openstack_client_role

        # TODO: Add wildfly roles.
        #- common.orchestrate.wraps.wildfly_node_1_role
        #- common.orchestrate.wraps.wildfly_node_2_role

        - common.orchestrate.wraps.vagrant_box_publisher_role

{% endif %}

###############################################################################
# EOF
###############################################################################

