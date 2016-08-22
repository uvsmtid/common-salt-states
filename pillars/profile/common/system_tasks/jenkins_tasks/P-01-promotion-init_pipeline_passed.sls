
###############################################################################
#

system_tasks:

    jenkins_tasks:

        {% set job_template_id = 'promotion-init_pipeline_passed' %}
        P-01-{{ job_template_id }}:

            enabled: True

            is_promotion: True

            restrict_to_system_role:
                - salt_master_role

            condition_job_list:
                - 01-04-init_pipeline-create_build_branches

            condition_type: downstream_passed
            accept_unstable: True
            promotion_icon: star-blue

            # Pass build parameters to `update_pipeline`.
            propagate_build_paramterers: True

            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 02-01-update_pipeline-restart_master_salt_services

            job_config_function_source: 'common/jenkins/configure_jobs_ext/promotable_xml_template_job.sls'
            job_config_data:
                xml_config_template: 'common/jenkins/configure_jobs_ext/promotion-template.xml'

###############################################################################
# EOF
###############################################################################

