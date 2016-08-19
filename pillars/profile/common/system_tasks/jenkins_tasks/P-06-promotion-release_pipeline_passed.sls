
###############################################################################
#

system_tasks:

    jenkins_tasks:

        {% set job_template_id = 'promotion-release_pipeline_passed' %}
        P-06-{{ job_template_id }}:

            enabled: True

            is_promotion: True

            restrict_to_system_role:
                - salt_master_role

            condition_job_list:
                - 06-07-release_pipeline-merge_build

            condition_type: downstream_passed
            accept_unstable: True
            promotion_icon: star-red-e

            # Do NOT pass build paramters to `checkout_pipeline` -
            # the pipeline is started with its own default paramters.
            propagate_build_paramterers: False

            # The `checkout_pipeline` is needed for manual triggering
            # when new package has to be generated.
            # However, it is executed anyway for testing purposes
            # with default parameters.
            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 07-01-checkout_pipeline-checkout_build_branches

            job_config_function_source: 'common/jenkins/configure_jobs_ext/promotable_xml_template_job.sls'
            job_config_data:
                xml_config_template: 'common/jenkins/configure_jobs_ext/promotion-template.xml'

###############################################################################
# EOF
###############################################################################

