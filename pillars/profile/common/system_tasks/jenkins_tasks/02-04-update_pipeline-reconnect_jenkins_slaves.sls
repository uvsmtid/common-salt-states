
###############################################################################
#

system_tasks:

    jenkins_tasks:

        # If set to `-1`, keep forever.
        {% set discard_build_days = 64 %}
        {% set discard_build_num = 128 %}

        {% set skip_script_execution = False %}

        {% set job_template_id = 'update_pipeline-reconnect_jenkins_slaves' %}
        02-04-{{ job_template_id }}:

            enabled: True

            job_group_name: update_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            # NOTE: This job is special.
            #       While many other jobs run through Jenkins Slaves
            #       (even if this Slave may run on Jenkins Master),
            #       this job is actually executed by Jenkins Master.
            #       This is required to be able to keep connection
            #       while executing reconnection for Slaves.
            force_jenkins_master: True
            restrict_to_system_role:
                - jenkins_master_role

            skip_if_true: SKIP_UPDATE_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml

            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 02-05-update_pipeline-generate_join_hosts_roles_networks_table

            job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
            job_config_data:
                xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

###############################################################################
# EOF
###############################################################################

