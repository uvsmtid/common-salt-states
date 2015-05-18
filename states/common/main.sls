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
        #- primary-console-role

        - common.orchestrate.wraps.controller-role

        # TODO:
        #- common.orchestrate.wraps.router-role
        #- common.orchestrate.wraps.resolver-role

        - common.orchestrate.wraps.hypervisor-role

        - common.orchestrate.wraps.depository-role

        - common.orchestrate.wraps.maven-build-server-role

        - common.orchestrate.wraps.jenkins-master-role
        - common.orchestrate.wraps.jenkins-slave-role

        # This wrap handles both:
        # - maven-repository-upstream-manager-role
        # - maven-repository-downstream-manager-role
        - common.orchestrate.wraps.maven-repository-manager-role

        - common.orchestrate.wraps.openstack-client-role

    # main
        - common.orchestrate.wraps.main

{% endif %}

###############################################################################
# EOF
###############################################################################

