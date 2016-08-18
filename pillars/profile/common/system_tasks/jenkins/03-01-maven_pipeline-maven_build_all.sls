
###############################################################################
#

system_tasks:

    jenkins_tasks:

        # If set to `-1`, keep forever.
        {% set discard_build_days = 64 %}
        {% set discard_build_num = 128 %}

        {% set skip_script_execution = False %}

        {% set job_template_id = 'maven_pipeline-maven_build_all' %}
        03-01-{{ job_template_id }}:

            enabled: True

            job_group_name: maven_pipeline_group

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
                ^(?=0[4-9]-\d\d)\d\d-\d\d.*$
                {% if False %}
                ^__-__.*$
                {% endif %}

            # TODO: At the moment Maven jobs cannot be skipped.
            skip_if_true: SKIP_MAVEN_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml

            parameterized_job_triggers:
                build_always:
                    # NOTE: Run Maven artifact verifications regardless
                    #       of build status as it is independent check.
                    condition: ALWAYS
                    trigger_jobs:
                        - 03-02-maven_pipeline-verify_maven_data

            disable_archiving: True

            # This job is not for analysis. It is only for initial build.
            sonarqube_runner: False

            # Specific goals and options.
            # Note that we run initial build - all repositories are
            # rebuilt subsequently in individual jobs.
            # What we need now is to build artefacts ONLY:
            # - Build without running tests.
            # - Make sure to build test jars as well
            #   (some components depend on tests jars).
            # - Skip integration tests.
            #   It seems that without `-DskipTests`, integration tests
            #   are still being run.
            #   See also:
            #       http://maven.apache.org/surefire/maven-failsafe-plugin/examples/skipping-test.html
            maven_args: 'clean test-compile install -Dmaven.test.skip=true -DskipTests'

            # Large multi-module reactor build often
            # runs out of memory without overriding defaults.
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

            # Instead of join, use promotion to trigger next pipeline.
            # Otherwise, the Build Pipeline View cannot handle join
            # and draws duplicated chains after each job to be joined.
            {% if False %}
            trigger_jobs_on_downstream_join:
                - 04-01-deploy_pipeline-register_generated_resources
            {% endif %}

            job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
            job_config_data:
                # NOTE: This job is simply a Maven build which uses
                # special `pom.xml` from parent repository which
                # spans all components by referencing them as modules.
                xml_config_template: 'common/jenkins/configure_jobs_ext/maven_pipeline-maven_project_job.xml'
                repository_name: 'maven-demo'
                component_pom_path: 'pom.xml'

###############################################################################
# EOF
###############################################################################

