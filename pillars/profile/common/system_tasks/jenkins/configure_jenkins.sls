
###############################################################################
#

system_tasks:

    jenkins_tasks:

        # If set to `-1`, keep forever.
        {% set discard_build_days = 64 %}
        {% set discard_build_num = 128 %}

        {% set skip_script_execution = False %}

        {% set job_template_id = 'checkout_pipeline-checkout_build_branches' %}
        07-01-{{ job_template_id }}:

            enabled: True

            job_group_name: checkout_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            restrict_to_system_role:
                - salt_master_role

            # 1. Block on any subsequent pipeplines.
            #    Jobs across pipelines may not have upstream/downstream
            #    relationship which may cause out of order execution.
            # 2. Do not get blocked by standalone jobs because
            #    standalone jobs are normally block on all
            #    (condition which would cause deadlock).
            block_build: |
                ^(?=0[8-9]-\d\d)\d\d-\d\d.*$
                {% if False %}
                ^__-__.*$
                {% endif %}

            skip_if_true: SKIP_CHECKOUT_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            archive_artifacts:
                # NOTE: We re-archive the same file which is
                #       restored from parent build.
                - initial.init_pipeline.dynamic_build_descriptor.yaml
                - initial.checkout_pipeline.dynamic_build_descriptor.yaml

            # NOTE: Even if we need to re-use this artifact from
            #       `init_pipeline-start_new_build` for association,
            #       the approach is to re-create this artifact
            #       (get from parent build) and archive it again instead
            #       of using Copy Artifact plugin
            #       (see `archive_artifacts`).
            #       Because we re-use existing artifact, the fingerprint
            #       will be the same and association with
            #       `init_pipeline-start_new_build` will happen again.
            #       Why not using Copy Artifact plugin?
            #       Because this build is triggered manually and copying
            #       artifact would resort to the latest build of
            #       `init_pipeline-start_new_build` instead of
            #       continuing based on parent build. We want
            #       to set all branches to condition met in some
            #       build in the past. This can only be done by
            #       the job itself which takes parent build parameter.
            #       And we also have to archive another artefact which
            #       originates in this job so that promotion jobs can
            #       see associations of downstream jobs with this one.
            {% if False %}
            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml
            {% endif %}

            # This list combined with value of
            # `initial_dynamic_build_descriptor` are part of
            # produced artifacts.
            restore_artifacts_from_parent_build:
                - initial.init_pipeline.dynamic_build_descriptor.yaml
            # The following parameter indicates artifact file name
            # which is fingerprinted to associate this job with
            # all downstream jobs (if they restore or copy it).
            initial_dynamic_build_descriptor: initial.checkout_pipeline.dynamic_build_descriptor.yaml

            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 07-02-checkout_pipeline-reset_previous_build

            # NOTE: This job is promotable and uses another config.
            job_config_function_source: 'common/jenkins/configure_jobs_ext/promotable_xml_template_job.sls'
            job_config_data:
                # NOTE: We reuse `init_pipeline-start_new_build` template.
                {% set job_template_id = 'init_pipeline-start_new_build' %}
                xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

            # NOTE: Instead of using `build_parameters`,
            #       `checkout_pipeline` fixes values of environment
            #       variables without user interface options.
            preset_build_parameters:
                # If `TARGET_PROFILE_NAME` is empty, `SALT_PROFILE_NAME`
                # is used - exactly what we want.
                TARGET_PROFILE_NAME: ''
                # Use `_` as no existing commits should be authored
                # by this invalid email value. There are not commits
                # in this pipeline - they should fail.
                AUTO_COMMIT_GIT_AUTHOR_EMAIL: '_'
                # NOTE: This variable is the reason why this entire
                #       `checkout_pipeline` exists.
                RESTORE_PARENT_BUILD_ONLY: 'true'

            build_parameters:
                PARENT_BUILD_TITLE:
                    parameter_description: |
                        Specify build title from existing history.
                        If this parameter is specified, then `init_pipeline-create_build_branches` job
                        sets HEADs of newly created build branches to `latest_commit_ids` from that build title;.
                        NOTE: The new build will have its own build title (and build branch names).
                        This is just a mechanism to reuse state of the build from the past
                        (for example, for release, packaging, or re-building).
                        The build title can be found in dynamic build descriptor in the value of `build_title` key.
                    parameter_type: string
                    parameter_value: '_'

                SKIP_CHECKOUT_PIPELINE:
                    parameter_description: |
                        TODO: Quick and dirty impl to skip pipeline.
                    parameter_type: boolean
                    parameter_value: False

            # DISABLED: Do not use promotions designed for `init_pipeline`
            #           because they are configured to trigger subsequent
            #           pipeline for testing purposes.
            #           If promotions are required, create new ones
            #           specific for this job/pipeline.
            {% if False %}
            use_promotions:
                - P-07-promotion-checkout_pipeline_passed
            {% endif %}

###############################################################################
# EOF
###############################################################################

###############################################################################
#

system_tasks:

    jenkins_tasks:

        # If set to `-1`, keep forever.
        {% set discard_build_days = 64 %}
        {% set discard_build_num = 128 %}

        {% set skip_script_execution = False %}

        {% set job_template_id = 'checkout_pipeline-reset_previous_build' %}
        07-02-{{ job_template_id }}:

            enabled: True

            send_email_notifications: False

            job_group_name: checkout_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            restrict_to_system_role:
                - salt_master_role

            skip_if_true: SKIP_CHECKOUT_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml
                07-01-checkout_pipeline-checkout_build_branches: initial.checkout_pipeline.dynamic_build_descriptor.yaml

            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 07-03-checkout_pipeline-describe_repositories_state

            job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
            job_config_data:
                # NOTE: We reuse `init_pipeline-reset_previous_build` template.
                {% set job_template_id = 'init_pipeline-reset_previous_build' %}
                xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

###############################################################################
# EOF
###############################################################################

###############################################################################
#

system_tasks:

    jenkins_tasks:

        # If set to `-1`, keep forever.
        {% set discard_build_days = 64 %}
        {% set discard_build_num = 128 %}

        {% set skip_script_execution = False %}

        {% set job_template_id = 'checkout_pipeline-describe_repositories_state' %}
        07-03-{{ job_template_id }}:

            enabled: True

            job_group_name: checkout_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            restrict_to_system_role:
                - salt_master_role

            skip_if_true: SKIP_CHECKOUT_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml
                07-01-checkout_pipeline-checkout_build_branches: initial.checkout_pipeline.dynamic_build_descriptor.yaml

            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 07-04-checkout_pipeline-create_build_branches

            job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
            job_config_data:
                # NOTE: We reuse `init_pipeline-describe_repositories_state` template.
                {% set job_template_id = 'init_pipeline-describe_repositories_state' %}
                xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

###############################################################################
# EOF
###############################################################################

###############################################################################
#

system_tasks:

    jenkins_tasks:

        # If set to `-1`, keep forever.
        {% set discard_build_days = 64 %}
        {% set discard_build_num = 128 %}

        {% set skip_script_execution = False %}

        {% set job_template_id = 'checkout_pipeline-create_build_branches' %}
        07-04-{{ job_template_id }}:

            enabled: True

            job_group_name: checkout_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            restrict_to_system_role:
                - salt_master_role

            skip_if_true: SKIP_CHECKOUT_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml
                07-01-checkout_pipeline-checkout_build_branches: initial.checkout_pipeline.dynamic_build_descriptor.yaml

            # This is the final job in the pipeline.
            {% if False %}
            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        []
            {% endif %}

            job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
            job_config_data:
                # NOTE: We reuse `init_pipeline-create_build_branches` template.
                {% set job_template_id = 'init_pipeline-create_build_branches' %}
                xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

###############################################################################
# EOF
###############################################################################

