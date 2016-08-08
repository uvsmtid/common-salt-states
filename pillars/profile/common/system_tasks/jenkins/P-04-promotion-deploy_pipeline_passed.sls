
###############################################################################
#

system_tasks:

    jenkins_tasks:

        {% set job_template_id = 'promotion-deploy_pipeline_passed' %}
        P-04-{{ job_template_id }}:

            enabled: True

            is_promotion: True

            restrict_to_system_role:
                - salt_master_role

            condition_job_list:

                # Demand completion of deployment.
                - 04-08-deploy_pipeline-run_salt_orchestrate
                - 04-09-deploy_pipeline-run_salt_highstate
                - 04-10-deploy_pipeline-reconnect_jenkins_slaves

            # Do NOT pass build paramters to `package_pipeline` -
            # the pipeline is started with its own default paramters.
            propagate_build_paramterers: False

            # The `package_pipeline` is needed for manual triggering
            # when new package has to be generated.
            # However, it is executed anyway for testing purposes
            # with default parameters.
            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 05-01-package_pipeline-create_new_package

            condition_type: downstream_passed
            accept_unstable: False
            promotion_icon: star-green

            job_config_function_source: 'common/jenkins/configure_jobs_ext/promotable_xml_template_job.sls'
            job_config_data:
                xml_config_template: 'common/jenkins/configure_jobs_ext/promotion-template.xml'

###############################################################################
# EOF
###############################################################################

