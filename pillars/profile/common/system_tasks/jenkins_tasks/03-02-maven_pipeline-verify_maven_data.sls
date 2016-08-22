
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

        {% set job_template_id = 'maven_pipeline-verify_maven_data' %}
        03-02-{{ job_template_id }}:

            enabled: True

            job_group_name: maven_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            restrict_to_system_role:
                - salt_master_role

            # TODO: At the moment Maven jobs cannot be skipped.
            skip_if_true: SKIP_MAVEN_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml

            parameterized_job_triggers:
                build_always:
                    # NOTE: Try to build individual Maven jobs
                    #       to update their status as well.
                    condition: ALWAYS
                    trigger_jobs:
                        {% for maven_repo_name in maven_repo_names %}
                        - 03-03-maven_pipeline-{{ maven_job_name_prefix }}-{{ maven_repo_name }}
                        {% endfor %}

            job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
            job_config_data:
                xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

###############################################################################
# EOF
###############################################################################

