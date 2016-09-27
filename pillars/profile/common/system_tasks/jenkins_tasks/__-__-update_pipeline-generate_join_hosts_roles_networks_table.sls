
###############################################################################
#

system_tasks:

    jenkins_tasks:

        # If set to `-1`, keep forever.
        {% set discard_build_days = 64 %}
        {% set discard_build_num = 128 %}

        {% set skip_script_execution = False %}

        {% set job_template_id = 'update_pipeline-generate_join_hosts_roles_networks_table' %}
        __-__-{{ job_template_id }}:

            enabled: True

            send_email_notifications: False

            job_group_name: standalone_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            restrict_to_system_role:
                - salt_master_role

            skip_if_true: SKIP_UPDATE_PIPELINE

            # NOTE: Standalone (outside of pipeline) jobs are executed on demand.
            skip_script_execution: False

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

            # List of profile names (one per line) to generate the table for.
            # Note that the local branches named after the listed profile names
            # are supposed to be already pre-created in bootstrap target profile repository.
            # NOTE: The table for this system profile_name is ALWAYS generated.
            target_profile_name_list:
                []

            build_parameters:

                TARGET_PROFILE_NAME:
                    parameter_description: |
                        Specify target profile to fetch data for the table.
                        Selecting `_` (default) means generating table
                        for ALL profile names specified in `target_profile_name_list`
                        (which is statically configured in pillars).
                        Specifying profile_name in `TARGET_PROFILE_NAME` reduces number of generated
                        tables to the single one (without `target_profile_name_list`).
                        NOTE: The table for this system profile_name is ALWAYS generated.
                    parameter_type: string
                    parameter_value:
                        _

###############################################################################
# EOF
###############################################################################

