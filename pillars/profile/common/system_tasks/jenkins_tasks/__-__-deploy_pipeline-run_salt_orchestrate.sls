
###############################################################################
#

system_tasks:

    jenkins_tasks:

        # If set to `-1`, keep forever.
        {% set discard_build_days = 64 %}
        {% set discard_build_num = 128 %}

        {% set skip_script_execution = False %}

        {% set job_template_id = 'deploy_pipeline-run_salt_orchestrate' %}
        __-__-{{ job_template_id }}:

            enabled: True

            send_email_notifications: False

            job_group_name: standalone_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            # NOTE: This job is special.
            #       While many other jobs run through Jenkins Slaves
            #       (even if this Slave may run on Jenkins Master),
            #       this job is actually executed by Jenkins Master.
            # NOTE: This is required as Jenkins Slaves may not yet
            #       have necessary SSH keys distributed
            #       (so, they may not be able to connect to master yet).
            # NOTE: We cannot run on true Jenkins Master
            #       (which is available on Jenkins by default)
            #       because its jobs executed by default user (`jenkins`)
            #       which may not have `sudo` enabled.
            #       Instead, we use Jenkins Slave which is connected
            #       via `localhost`.
            force_jenkins_master: False
            jenkins_master_role: localhost_role
            restrict_to_system_role:
                - localhost_role

            skip_if_true: SKIP_DEPLOY_PIPELINE

            # NOTE: Standalone (outside of pipeline) jobs are executed on demand.
            skip_script_execution: False

            # This disables error detection on this job.
            neglect_run_salt_orchestrate_error_state: False

            # NOTE: This is a standalone job and does not associate.
            {% if False %}
            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml
            {% endif %}

            # NOTE: This is a standalone job.
            {% if False %}
            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        []
            {% endif %}

            job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
            job_config_data:
                xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

###############################################################################
# EOF
###############################################################################

