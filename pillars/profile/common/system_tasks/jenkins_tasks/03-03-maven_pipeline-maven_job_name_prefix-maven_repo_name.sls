
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

        {% for maven_repo_name in maven_repo_names %}

        03-03-maven_pipeline-{{ maven_job_name_prefix }}-{{ maven_repo_name }}:

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

            # This is the final job in the pipeline.
            {% if False %}
            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        []
            {% endif %}

            disable_archiving: True

            sonarqube_runner: True

            # Similar to `maven_build_all`, use more memory.
            # See also:
            #   https://cwiki.apache.org/confluence/display/MAVEN/OutOfMemoryError
            MAVEN_OPTS: '-Xmx2048m -XX:MaxPermSize=512m'

            # TODO: Actually, this does not select JDK properly because
            #       started JVM (java executable) is still different.
            # NOTE: This variables has to be synced with deployment
            #       of specific JDK referred here.
            job_environment_variables:
                JAVA_HOME: '/usr/java/jdk1.7.0_71'
                PATH: '/usr/java/jdk1.7.0_71/bin:${PATH}'

            job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
            job_config_data:
                xml_config_template: 'common/jenkins/configure_jobs_ext/maven_pipeline-maven_project_job.xml'
                repository_name: {{ maven_repo_name }}
                # Some repositories do not have `pom.xml` in default location.
                # Note that at the moment all repo's roots
                # were supplied with pom.xml.
                {% if not maven_repo_name %}
                {{ FAIL_here }}
                {% else %}
                component_pom_path: 'pom.xml'
                {% endif %}

        {% endfor %}

###############################################################################
# EOF
###############################################################################

