
###############################################################################
#

system_tasks:

    jenkins_tasks:

        {% set job_template_id = 'promotion-update_pipeline_passed' %}
        P-02-{{ job_template_id }}:

            enabled: True

            is_promotion: True

            restrict_to_system_role:
                - salt_master_role

            condition_job_list:
                - 02-01-update_pipeline-restart_master_salt_services
                - 02-02-update_pipeline-configure_jenkins_jobs
                - 02-03-update_pipeline-run_salt_highstate
                - 02-04-update_pipeline-reconnect_jenkins_slaves
                - 02-05-update_pipeline-generate_join_hosts_roles_networks_table

            condition_type: downstream_passed
            accept_unstable: True
            promotion_icon: star-purple

            # Pass build parameters to `maven_pipeline`.
            propagate_build_paramterers: True

            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 03-01-maven_pipeline-maven_build_all

            job_config_function_source: 'common/jenkins/configure_jobs_ext/promotable_xml_template_job.sls'
            job_config_data:
                xml_config_template: 'common/jenkins/configure_jobs_ext/promotion-template.xml'

###############################################################################
# EOF
###############################################################################

