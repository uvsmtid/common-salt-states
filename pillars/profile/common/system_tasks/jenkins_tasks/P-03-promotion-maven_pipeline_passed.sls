
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

        {% set job_template_id = 'promotion-maven_pipeline_passed' %}
        P-03-{{ job_template_id }}:

            enabled: True

            is_promotion: True

            restrict_to_system_role:
                - salt_master_role

            condition_job_list:
                - 03-01-maven_pipeline-maven_build_all
                - 03-02-maven_pipeline-verify_maven_data
                {% for maven_repo_name in maven_repo_names %}
                - 03-03-maven_pipeline-{{ maven_job_name_prefix }}-{{ maven_repo_name }}
                {% endfor %}

            condition_type: downstream_passed
            accept_unstable: False
            promotion_icon: star-gold

            # Pass build paramters to `deploy_pipeline`.
            propagate_build_paramterers: True

            parameterized_job_triggers:
                job_not_faild:
                    condition: SUCCESS
                    trigger_jobs:
                        - 04-01-deploy_pipeline-register_generated_resources

            job_config_function_source: 'common/jenkins/configure_jobs_ext/promotable_xml_template_job.sls'
            job_config_data:
                xml_config_template: 'common/jenkins/configure_jobs_ext/promotion-template.xml'

###############################################################################
# EOF
###############################################################################

