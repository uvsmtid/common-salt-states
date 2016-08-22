
###############################################################################
#

system_tasks:

    jenkins_tasks:

        # If set to `-1`, keep forever.
        {% set discard_build_days = 64 %}
        {% set discard_build_num = 128 %}

        {% set skip_script_execution = False %}

        {% set job_template_id = 'poll_pipeline-verify_approval' %}
        00-01-{{ job_template_id }}:

            enabled: True

            job_group_name: poll_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            restrict_to_system_role:
                - salt_master_role

            # 1. Block on any pipeline job except start of `init_pipeline`.
            #    The job will still wait on already executing `01-01`.
            # 2. Do not get blocked by standalone jobs because
            #    standalone jobs are normally block on all
            #    (condition which would cause deadlock).
            block_build: |
                ^(?!01-01)\d\d-\d\d.*$
                {% if False %}
                ^__-__.*$
                {% endif %}

            timer_spec: '*/10 * * * *'

            skip_if_true: SKIP_POLL_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            parameterized_job_triggers:
                job_not_faild:
                    condition: SUCCESS
                    trigger_jobs:
                        - 00-02-poll_pipeline-reset_previous_build

            job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
            job_config_data:
                xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

###############################################################################
# EOF
###############################################################################

