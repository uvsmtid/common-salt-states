
###############################################################################
#

system_tasks:

    jenkins_tasks:

        # If set to `-1`, keep forever.
        {% set discard_build_days = 64 %}
        {% set discard_build_num = 128 %}

        {% set skip_script_execution = False %}

        {% set job_template_id = 'poll_pipeline-reset_previous_build' %}
        00-02-{{ job_template_id }}:

            enabled: True

            send_email_notifications: False

            job_group_name: poll_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            restrict_to_system_role:
                - salt_master_role

            skip_if_true: SKIP_POLL_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 00-03-poll_pipeline-update_sources

            job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
            job_config_data:
                # NOTE: This is the same job as `reset_previous_build`.
                #       It just have different configuration.
                {% set job_template_id = 'init_pipeline-reset_previous_build' %}
                xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

###############################################################################
# EOF
###############################################################################

