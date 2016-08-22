
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set project_name = props['project_name'] %}
{% set profile_name = props['profile_name'] %}
{% set master_minion_id = props['master_minion_id'] %}
{% set default_username = props['default_username'] %}

# Import `maven_repo_names`.
{% set maven_repo_names_path = profile_root.replace('.', '/') + '/common/system_maven_artifacts/maven_repo_names.yaml' %}
{% import_yaml maven_repo_names_path as maven_repo_names %}

{% set maven_job_name_prefix = 'build_repo' %}

system_tasks:

    jenkins_tasks:

        # If set to `-1`, keep forever.
        {% set discard_build_days = 64 %}
        {% set discard_build_num = 128 %}

        {% set skip_script_execution = False %}

        {% set job_template_id = 'init_pipeline-start_new_build' %}
        01-01-{{ job_template_id }}:

            enabled: True

            track_scm_changes: True

            job_group_name: init_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            restrict_to_system_role:
                - salt_master_role

            # 1. Block by any pipeline jobs in `poll_pipeline`.
            #    Blocking on any jobs is required as `init_pipeline`
            #    does not have upstream/downstream relationship
            #    with `poll_pipeline`.
            # 2. Block on any subsequent pipeplines.
            #    Jobs across pipelines may not have upstream/downstream
            #    relationship which may cause out of order execution.
            # 3. Do not get blocked by standalone jobs because
            #    standalone jobs are normally block on all
            #    (condition which would cause deadlock).
            block_build: |
                ^(?=00-\d\d)\d\d-\d\d.*$
                ^(?=0[2-9]-\d\d)\d\d-\d\d.*$
                {% if False %}
                ^__-__.*$
                {% endif %}

            # NOTE: Build once a day after office hours.
            #       This is in addition to SCM trigger.
            #       Use early morning to keep timestamps within
            #       the same date.
            timer_spec: 'H 01 * * *'

            scm_poll_timer_spec: '*/1 * * * *'

            skip_if_true: SKIP_INIT_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            archive_artifacts:
                # NOTE: This is the file which fingerprint allows
                #       associate all jobs in the pipelines together.
                - initial.init_pipeline.dynamic_build_descriptor.yaml

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
            # NOTE: This is the very first job - it cannot
            #       be asssociated with itself.
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
            initial_dynamic_build_descriptor: initial.init_pipeline.dynamic_build_descriptor.yaml

            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 01-02-init_pipeline-reset_previous_build

            # NOTE: This job is promotable and uses another config.
            job_config_function_source: 'common/jenkins/configure_jobs_ext/promotable_xml_template_job.sls'
            job_config_data:
                xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

            preset_build_parameters:
                # NOTE: This variable is `true` only in `checkout_pipeline`.
                RESTORE_PARENT_BUILD_ONLY: 'false'
                # Set default version name.
                RELEASE_VERSION_NAME: '{{ project_name }}'

            build_parameters:
                BUILD_LABEL:
                    parameter_description: |
                        Short meaningful string to differentiate this build.
                        It is embedded into build title.
                    parameter_type: string
                    parameter_value: '_'
                BUILD_NOTES:
                    parameter_description: |
                        Any notes describing the build.
                    parameter_type: text
                    parameter_value: '_'
                MAVEN_SKIP_TESTS:
                    parameter_description: |
                        TODO: Skip tests.
                    parameter_type: boolean
                    parameter_value: False
                OBFUSCATE_JAVA_CODE:
                    parameter_description: |
                        TODO: Enable obfuscation.
                    parameter_type: boolean
                    parameter_value: False
                AUTO_COMMIT_GIT_AUTHOR_EMAIL:
                    parameter_description: |
                        Specify author email for Git commits.
                        The value will be used with `--author` option for all Git commits made automatically.
                        Substring can be used if it is uniquely identifies author within existing commits.
                        Full format: `First Last &lt;email@example.com&gt;`
                    parameter_type: string
                    parameter_value: '_'
                PARENT_BUILD_TITLE:
                    parameter_description: |
                        Specify build title from existing history.
                        If this parameter is specified, then `init_pipeline-create_build_branches` job
                        sets HEADs of newly created build branches to `latest_commit_ids` from that build title.
                        NOTE: The new build will have its own build title (and build branch names).
                        This is just a mechanism to reuse state of the build from the past
                        (for example, for release, packaging, or re-building).
                        The build title can be found in dynamic build descriptor in the value of `build_title` key.
                    parameter_type: string
                    parameter_value: '_'

                SKIP_INIT_PIPELINE:
                    parameter_description: |
                        TODO: Quick and dirty impl to skip pipeline.
                    parameter_type: boolean
                    parameter_value: False
                SKIP_UPDATE_PIPELINE:
                    parameter_description: |
                        TODO: Quick and dirty impl to skip pipeline.
                    parameter_type: boolean
                    parameter_value: False
                SKIP_MAVEN_PIPELINE:
                    parameter_description: |
                        TODO: Quick and dirty impl to skip pipeline.
                    parameter_type: boolean
                    parameter_value: False
                SKIP_DEPLOY_PIPELINE:
                    parameter_description: |
                        TODO: Quick and dirty impl to skip pipeline.
                    parameter_type: boolean
                    parameter_value: False

            use_promotions:
                - P-01-promotion-init_pipeline_passed
                - P-02-promotion-update_pipeline_passed
                - P-03-promotion-maven_pipeline_passed
                - P-04-promotion-deploy_pipeline_passed
                - P-05-promotion-package_pipeline_passed
                - P-06-promotion-release_pipeline_passed
                - P-07-promotion-checkout_pipeline_passed
                - P-__-promotion-bootstrap_package_approved

###############################################################################
# EOF
###############################################################################

