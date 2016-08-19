
###############################################################################
#

system_tasks:

    jenkins_tasks:

        # If set to `-1`, keep forever.
        {% set discard_build_days = 64 %}
        {% set discard_build_num = 128 %}

        {% set skip_script_execution = False %}

        {% set job_template_id = 'maven_pipeline-full_test_report' %}
        __-__-{{ job_template_id }}:

            enabled: True

            job_group_name: standalone_group

            discard_old_builds:
                # NOTE: Keep history forever.
                build_days: -1
                build_num: -1

            restrict_to_system_role:
                - salt_master_role

            # 1. Block on all jobs.
            block_build: |
                ^.*$

            # NOTE: Build once a day after office hours.
            #       Use early morning to keep timestamps within
            #       the same date after full pipeline build.
            timer_spec: 'H 05 * * *'

            # TODO: At the moment Maven jobs cannot be skipped.
            skip_if_true: SKIP_MAVEN_PIPELINE

            # NOTE: Standalone (outside of pipeline) jobs are executed on demand.
            skip_script_execution: False

            # NOTE: This is a standalone job and does not associate.
            {% if False %}
            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml
            {% endif %}

            # This is a standalone job which runs outside of the pipeline.
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
                # Specify root pom.xml file which triggers full
                # multi-module reactor build.
                repository_name: 'maven-demo'
                component_pom_path: 'pom.xml'

###############################################################################
# EOF
###############################################################################

