
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

        {% set job_template_id = 'deploy_pipeline-register_generated_resources' %}
        04-01-{{ job_template_id }}:

            enabled: True

            job_group_name: deploy_pipeline_group

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
                ^(?=0[5-9]-\d\d)\d\d-\d\d.*$
                {% if False %}
                ^__-__.*$
                {% endif %}

            skip_if_true: SKIP_DEPLOY_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml

            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 04-02-deploy_pipeline-transfer_dynamic_build_descriptor

            job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
            job_config_data:
                # NOTE: It is project-specific job configuration.
                {% if project_name == 'common' %}
                # This is a template.
                xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'
                {% else %}
                xml_config_template: '{{ project_name }}/jenkins/job_configurations/{{ job_template_id }}.xml'
                {% endif %}

###############################################################################
# EOF
###############################################################################

