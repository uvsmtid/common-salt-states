
###############################################################################
#

system_tasks:

    jenkins_tasks:

        # If set to `-1`, keep forever.
        {% set discard_build_days = 64 %}
        {% set discard_build_num = 128 %}

        {% set skip_script_execution = False %}

        {% set job_template_id = 'deploy_pipeline-remove_salt_minion_keys' %}
        04-06-{{ job_template_id }}:

            enabled: True

            job_group_name: deploy_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            # NOTE: This job is special.
            #       While many other jobs run through Jenkins Slaves
            #       (even if this Slave may run on Jenkins Master),
            #       this job is actually executed by Jenkins Master.
            # NOTE: This is required because even Jenkins Slave
            #       running on the same host with Jenkins Master
            #       may not have necessary (virtual) network configured
            #       as it may be created only with (Vagrant) VMs
            #       Such Jenkins Slave may be inaccessible by
            #       its known IP address to master yet.
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

            # NOTE: This step may avoid destroying Vagrant hosts
            #       because this process is not yet reliable enough.
            # NOTE: There are also some manual steps (e.g. screen resolution)
            #       which are not configured automatically yet.
            skip_script_execution: {{ skip_script_execution }}

            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml

            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 04-07-deploy_pipeline-instantiate_vagrant_hosts

            job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
            job_config_data:
                xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

###############################################################################
# EOF
###############################################################################

