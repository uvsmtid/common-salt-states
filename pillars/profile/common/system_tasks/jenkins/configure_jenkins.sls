
###############################################################################
#

system_tasks:

    jenkins_tasks:

        {% set skip_script_execution = False %}

        {% set job_template_id = 'update_pipeline-restart_master_salt_services' %}
        __-__-{{ job_template_id }}:

            enabled: True

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

        {% set job_template_id = 'update_pipeline-configure_jenkins_jobs' %}
        __-__-{{ job_template_id }}:

            enabled: True

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

        {% set job_template_id = 'update_pipeline-restart_master_salt_services' %}
        02-01-{{ job_template_id }}:

            enabled: True

            job_group_name: update_pipeline_group

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
                ^(?=0[3-9]-\d\d)\d\d-\d\d.*$
                {% if False %}
                ^__-__.*$
                {% endif %}

            skip_if_true: SKIP_UPDATE_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial-init_pipeline-dynamic_build_descriptor.yaml

            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 02-02-update_pipeline-configure_jenkins_jobs

            job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
            job_config_data:
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

        {% set job_template_id = 'update_pipeline-configure_jenkins_jobs' %}
        02-02-{{ job_template_id }}:

            enabled: True

            job_group_name: update_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            restrict_to_system_role:
                - salt_master_role

            skip_if_true: SKIP_UPDATE_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml

            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 02-03-update_pipeline-run_salt_highstate

            job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
            job_config_data:
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

        {% set job_template_id = 'update_pipeline-run_salt_highstate' %}
        02-03-{{ job_template_id }}:

            enabled: True

            job_group_name: update_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            restrict_to_system_role:
                - salt_master_role

            skip_if_true: SKIP_UPDATE_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml

            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 02-04-update_pipeline-reconnect_jenkins_slaves

            job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
            job_config_data:
                # NOTE: This job cloned from `deploy_pipeline`.
                {% set job_template_id = 'deploy_pipeline-run_salt_highstate' %}
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

        {% set job_template_id = 'update_pipeline-reconnect_jenkins_slaves' %}
        02-04-{{ job_template_id }}:

            enabled: True

            job_group_name: update_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            # NOTE: This job is special.
            #       While many other jobs run through Jenkins Slaves
            #       (even if this Slave may run on Jenkins Master),
            #       this job is actually executed by Jenkins Master.
            #       This is required to be able to keep connection
            #       while executing reconnection for Slaves.
            force_jenkins_master: True
            restrict_to_system_role:
                - jenkins_master_role

            skip_if_true: SKIP_UPDATE_PIPELINE

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

            job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
            job_config_data:
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

###############################################################################
#

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

###############################################################################
#

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

###############################################################################
#

system_tasks:

    jenkins_tasks:

        # If set to `-1`, keep forever.
        {% set discard_build_days = 64 %}
        {% set discard_build_num = 128 %}

        {% set skip_script_execution = False %}

        {% set job_template_id = 'deploy_pipeline-build_bootstrap_package' %}
        __-__-{{ job_template_id }}:

            enabled: True

            job_group_name: standalone_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            restrict_to_system_role:
                - salt_master_role

            skip_if_true: SKIP_DEPLOY_PIPELINE

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
                # NOTE: This job cloned from `package_pipeline`.
                {% set job_template_id = 'package_pipeline-build_bootstrap_package' %}
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

        {% set job_template_id = 'deploy_pipeline-configure_vagrant' %}
        __-__-{{ job_template_id }}:

            enabled: True

            job_group_name: standalone_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            restrict_to_system_role:
                - salt_master_role

            skip_if_true: SKIP_DEPLOY_PIPELINE

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

        {% set job_template_id = 'deploy_pipeline-destroy_vagrant_hosts' %}
        __-__-{{ job_template_id }}:

            enabled: True

            job_group_name: standalone_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            # NOTE: This job is special.
            #       While many other jobs run through Jenkins Slaves
            #       (even if this Slave may run on Jenkins Master),
            #       this job is actually executed by Jenkins Master.
            # NOTE: This is required because even Jenkins Slave
            #       running on the same host with Jenkins Master
            #       will destroy its network (together with its
            #       connection to master) while destroying (Vagrant) VMs.
            #       This will fail the job with error:
            #           Slave went offline during the build
            # NOTE: We cannot run on true Jenkins Master
            #       (which is available on Jenkins by default)
            #       because its jobs executed by default user (`jenkins`)
            #       which may not have access to Vagrant file.
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

        {% set job_template_id = 'deploy_pipeline-remove_salt_minion_keys' %}
        __-__-{{ job_template_id }}:

            enabled: True

            job_group_name: standalone_group

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

        {% set job_template_id = 'deploy_pipeline-instantiate_vagrant_hosts' %}
        __-__-{{ job_template_id }}:

            enabled: True

            job_group_name: standalone_group

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
            #       which may not have access to Vagrant file.
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

        {% set job_template_id = 'deploy_pipeline-run_salt_orchestrate' %}
        __-__-{{ job_template_id }}:

            enabled: True

            job_group_name: standalone_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            # NOTE: This job is special.
            #       While many other jobs run through Jenkins Slaves
            #       (even if this Slave may run on Jenkins Master),
            #       this job is actually executed by Jenkins Master.
            # NOTE: This is required as Jenkins Slaves may not yet
            #       have necessary SSH keys distributed
            #       (so, they may not be able to connect to master yet).
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

            # NOTE: Standalone (outside of pipeline) jobs are executed on demand.
            skip_script_execution: False

            # This disables error detection on this job.
            neglect_run_salt_orchestrate_error_state: False

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

        {% set job_template_id = 'deploy_pipeline-run_salt_highstate' %}
        __-__-{{ job_template_id }}:

            enabled: True

            job_group_name: standalone_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            # NOTE: This job is special.
            #       While many other jobs run through Jenkins Slaves
            #       (even if this Slave may run on Jenkins Master),
            #       this job is actually executed by Jenkins Master.
            # NOTE: This is required as Jenkins Slaves may not yet
            #       have necessary SSH keys distributed
            #       (so, they may not be able to connect to master yet).
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

        {% set job_template_id = 'deploy_pipeline-reconnect_jenkins_slaves' %}
        __-__-{{ job_template_id }}:

            enabled: True

            job_group_name: standalone_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            # NOTE: This job is special.
            #       While many other jobs run through Jenkins Slaves
            #       (even if this Slave may run on Jenkins Master),
            #       this job is actually executed by Jenkins Master.
            #       This is required to be able to keep connection
            #       while executing reconnection for Slaves.
            force_jenkins_master: True
            restrict_to_system_role:
                - jenkins_master_role

            skip_if_true: SKIP_DEPLOY_PIPELINE

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
                # NOTE: We reuse `update_pipeline-reconnect_jenkins_slaves` template.
                {% set job_template_id = 'update_pipeline-reconnect_jenkins_slaves' %}
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

###############################################################################
#

system_tasks:

    jenkins_tasks:

        # If set to `-1`, keep forever.
        {% set discard_build_days = 64 %}
        {% set discard_build_num = 128 %}

        {% set skip_script_execution = False %}

        {% set job_template_id = 'deploy_pipeline-transfer_dynamic_build_descriptor' %}
        04-02-{{ job_template_id }}:

            enabled: True

            job_group_name: deploy_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            restrict_to_system_role:
                - salt_master_role

            skip_if_true: SKIP_DEPLOY_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml

            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 04-03-deploy_pipeline-build_bootstrap_package

            job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
            job_config_data:
                # NOTE: This job cloned from `package_pipeline`.
                {% set job_template_id = 'package_pipeline-transfer_dynamic_build_descriptor' %}
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

        {% set job_template_id = 'deploy_pipeline-build_bootstrap_package' %}
        04-03-{{ job_template_id }}:

            enabled: True

            job_group_name: deploy_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            restrict_to_system_role:
                - salt_master_role

            skip_if_true: SKIP_DEPLOY_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml

            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 04-04-deploy_pipeline-configure_vagrant

            job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
            job_config_data:
                # NOTE: This job cloned from `package_pipeline`.
                {% set job_template_id = 'package_pipeline-build_bootstrap_package' %}
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

        {% set job_template_id = 'deploy_pipeline-configure_vagrant' %}
        04-04-{{ job_template_id }}:

            enabled: True

            job_group_name: deploy_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            restrict_to_system_role:
                - salt_master_role

            skip_if_true: SKIP_DEPLOY_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml

            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 04-05-deploy_pipeline-destroy_vagrant_hosts

            job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
            job_config_data:
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

        {% set job_template_id = 'deploy_pipeline-destroy_vagrant_hosts' %}
        04-05-{{ job_template_id }}:

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
            #       will destroy its network (together with its
            #       connection to master) while destroying (Vagrant) VMs.
            #       This will fail the job with error:
            #           Slave went offline during the build
            # NOTE: We cannot run on true Jenkins Master
            #       (which is available on Jenkins by default)
            #       because its jobs executed by default user (`jenkins`)
            #       which may not have access to Vagrant file.
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
                        - 04-06-deploy_pipeline-remove_salt_minion_keys

            job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
            job_config_data:
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

###############################################################################
#

system_tasks:

    jenkins_tasks:

        # If set to `-1`, keep forever.
        {% set discard_build_days = 64 %}
        {% set discard_build_num = 128 %}

        {% set skip_script_execution = False %}

        {% set job_template_id = 'deploy_pipeline-instantiate_vagrant_hosts' %}
        04-07-{{ job_template_id }}:

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
            #       which may not have access to Vagrant file.
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
                        - 04-08-deploy_pipeline-run_salt_orchestrate

            job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
            job_config_data:
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

        {% set job_template_id = 'deploy_pipeline-run_salt_orchestrate' %}
        04-08-{{ job_template_id }}:

            enabled: True

            job_group_name: deploy_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            # NOTE: This job is special.
            #       While many other jobs run through Jenkins Slaves
            #       (even if this Slave may run on Jenkins Master),
            #       this job is actually executed by Jenkins Master.
            # NOTE: This is required as Jenkins Slaves may not yet
            #       have necessary SSH keys distributed
            #       (so, they may not be able to connect to master yet).
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

            skip_script_execution: {{ skip_script_execution }}

            # This disables error detection on this job.
            neglect_run_salt_orchestrate_error_state: False

            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml

            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 04-09-deploy_pipeline-run_salt_highstate

            job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
            job_config_data:
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

        {% set job_template_id = 'deploy_pipeline-run_salt_highstate' %}
        04-09-{{ job_template_id }}:

            enabled: True

            job_group_name: deploy_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            # NOTE: This job is special.
            #       While many other jobs run through Jenkins Slaves
            #       (even if this Slave may run on Jenkins Master),
            #       this job is actually executed by Jenkins Master.
            # NOTE: This is required as Jenkins Slaves may not yet
            #       have necessary SSH keys distributed
            #       (so, they may not be able to connect to master yet).
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

            skip_script_execution: {{ skip_script_execution }}

            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml

            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 04-10-deploy_pipeline-reconnect_jenkins_slaves

            job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
            job_config_data:
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

        {% set job_template_id = 'deploy_pipeline-reconnect_jenkins_slaves' %}
        04-10-{{ job_template_id }}:

            enabled: True

            job_group_name: deploy_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            # NOTE: This job is special.
            #       While many other jobs run through Jenkins Slaves
            #       (even if this Slave may run on Jenkins Master),
            #       this job is actually executed by Jenkins Master.
            #       This is required to be able to keep connection
            #       while executing reconnection for Slaves.
            force_jenkins_master: True
            restrict_to_system_role:
                - jenkins_master_role

            skip_if_true: SKIP_DEPLOY_PIPELINE

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

            job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
            job_config_data:
                # NOTE: We reuse `update_pipeline-reconnect_jenkins_slaves` template.
                {% set job_template_id = 'update_pipeline-reconnect_jenkins_slaves' %}
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

        {% set job_template_id = 'package_pipeline-create_new_package' %}
        05-01-{{ job_template_id }}:

            enabled: True

            job_group_name: package_pipeline_group

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
                ^(?=0[6-9]-\d\d)\d\d-\d\d.*$
                {% if False %}
                ^__-__.*$
                {% endif %}

            skip_if_true: SKIP_PACKAGE_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            archive_artifacts:
                # NOTE: We re-archive the same file which is
                #       restored from parent build.
                - initial-init_pipeline-dynamic_build_descriptor.yaml
                - initial-package_pipeline-dynamic_build_descriptor.yaml

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
            initial_dynamic_build_descriptor: initial.package_pipeline.dynamic_build_descriptor.yaml

            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 05-02-package_pipeline-reset_previous_build

            # NOTE: This job is promotable and uses another config.
            job_config_function_source: 'common/jenkins/configure_jobs_ext/promotable_xml_template_job.sls'
            job_config_data:
                # NOTE: We reuse `init_pipeline-start_new_build` template.
                {% set job_template_id = 'init_pipeline-start_new_build' %}
                xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

            preset_build_parameters:
                # NOTE: This variable is `true` only in `checkout_pipeline`.
                RESTORE_PARENT_BUILD_ONLY: 'false'
                # Set default version name.
                RELEASE_VERSION_NAME: '{{ project_name }}'

            build_parameters:
                TARGET_PROFILE_NAME:
                    parameter_description: |
                        Specify target profile for bootstrap package.
                        It is embedded into package title.
                        Note that SOURCE_PROFILE is determined automatically.
                    parameter_type: choice
                    parameter_value:
                        # TODO: Provide list of pre-configured
                        #       names of `bootstrap_target_profile`.
                        []
                PACKAGE_LABEL:
                    parameter_description: |
                        Short meaningful string to differentiate this build.
                        It is embedded into package title.
                    parameter_type: string
                    parameter_value: '_'
                PACKAGE_NOTES:
                    parameter_description: |
                        Any notes describing the package.
                    parameter_type: text
                    parameter_value: '_'
                AUTO_COMMIT_GIT_AUTHOR_EMAIL:
                    parameter_description: |
                        Specify author email for Git commits.
                        The value will be used with `--author` option for all Git commits made automatically.
                        Substring can be used if it is uniquely identifies author within existing commits.
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

                SKIP_PACKAGE_PIPELINE:
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
                - P-05-promotion-package_pipeline_passed
                - P-__-promotion-bootstrap_package_approved
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

        {% set job_template_id = 'package_pipeline-reset_previous_build' %}
        05-02-{{ job_template_id }}:

            enabled: True

            send_email_notifications: False

            job_group_name: package_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            restrict_to_system_role:
                - salt_master_role

            skip_if_true: SKIP_PACKAGE_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml
                05-01-package_pipeline-create_new_package: initial.package_pipeline.dynamic_build_descriptor.yaml

            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 05-03-package_pipeline-describe_repositories_state

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

        {% set job_template_id = 'package_pipeline-describe_repositories_state' %}
        05-03-{{ job_template_id }}:

            enabled: True

            job_group_name: package_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            restrict_to_system_role:
                - salt_master_role

            skip_if_true: SKIP_PACKAGE_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml
                05-01-package_pipeline-create_new_package: initial.package_pipeline.dynamic_build_descriptor.yaml

            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 05-04-package_pipeline-create_build_branches

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

        {% set job_template_id = 'package_pipeline-create_build_branches' %}
        05-04-{{ job_template_id }}:

            enabled: True

            job_group_name: package_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            restrict_to_system_role:
                - salt_master_role

            skip_if_true: SKIP_PACKAGE_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml
                05-01-package_pipeline-create_new_package: initial.package_pipeline.dynamic_build_descriptor.yaml

            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 05-05-package_pipeline-transfer_dynamic_build_descriptor

            job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
            job_config_data:
                # NOTE: We reuse `init_pipeline-create_build_branches` template.
                {% set job_template_id = 'init_pipeline-create_build_branches' %}
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

        {% set job_template_id = 'package_pipeline-transfer_dynamic_build_descriptor' %}
        05-05-{{ job_template_id }}:

            enabled: True

            job_group_name: package_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            restrict_to_system_role:
                - salt_master_role

            skip_if_true: SKIP_PACKAGE_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml
                05-01-package_pipeline-create_new_package: initial.package_pipeline.dynamic_build_descriptor.yaml

            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 05-06-package_pipeline-build_bootstrap_package

            job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
            job_config_data:
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

        {% set job_template_id = 'package_pipeline-build_bootstrap_package' %}
        05-06-{{ job_template_id }}:

            enabled: True

            job_group_name: package_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            restrict_to_system_role:
                - salt_master_role

            skip_if_true: SKIP_PACKAGE_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml
                05-01-package_pipeline-create_new_package: initial.package_pipeline.dynamic_build_descriptor.yaml

            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 05-07-package_pipeline-store_bootstrap_package

            job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
            job_config_data:
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

        {% set job_template_id = 'package_pipeline-store_bootstrap_package' %}
        05-07-{{ job_template_id }}:

            enabled: True

            job_group_name: package_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            restrict_to_system_role:
                - salt_master_role

            skip_if_true: SKIP_PACKAGE_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml
                05-01-package_pipeline-create_new_package: initial.package_pipeline.dynamic_build_descriptor.yaml

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

        {% set job_template_id = 'release_pipeline-release_build' %}
        06-01-{{ job_template_id }}:

            enabled: True

            job_group_name: release_pipeline_group

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
                ^(?=0[7-9]-\d\d)\d\d-\d\d.*$
                {% if False %}
                ^__-__.*$
                {% endif %}

            skip_if_true: SKIP_RELEASE_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            archive_artifacts:
                # NOTE: We re-archive the same file which is
                #       restored from parent build.
                - initial.init_pipeline.dynamic_build_descriptor.yaml
                - initial.release_pipeline.dynamic_build_descriptor.yaml

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
            initial_dynamic_build_descriptor: initial.release_pipeline.dynamic_build_descriptor.yaml

            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 06-02-release_pipeline-reset_previous_build

            # NOTE: This job is promotable and uses another config.
            job_config_function_source: 'common/jenkins/configure_jobs_ext/promotable_xml_template_job.sls'
            job_config_data:
                # NOTE: We reuse `init_pipeline-start_new_build` template.
                {% set job_template_id = 'init_pipeline-start_new_build' %}
                xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

            preset_build_parameters:
                # NOTE: This variable is `true` only in `checkout_pipeline`.
                RESTORE_PARENT_BUILD_ONLY: 'false'

            build_parameters:
                RELEASE_TYPE:
                    parameter_description: |
                        Release types affects versioning and tagging rules.
                    parameter_type: choice
                    parameter_value:
                        - INCREMENTAL_RELEASE
                        - SEMANTIC_RELEASE
                RELEASE_VERSION_NAME:
                    parameter_description: |
                        Name of the released product/project.
                        It is embedded into release title (tag).
                    parameter_type: string
                    # Default version name.
                    parameter_value: '{{ project_name }}'
                RELEASE_VERSION_NUMBER:
                    parameter_description: |
                        Version number should have format `X.Y.Z.N`.
                        It is embedded into release title (tag).
                    parameter_type: string
                    parameter_value: '_'
                RELEASE_LABEL:
                    parameter_description: |
                        Short meaningful string to differentiate this release.
                        It is embedded into release title (tag).
                    parameter_type: string
                    parameter_value: '_'
                RELEASE_NOTES:
                    parameter_description: |
                        Any notes describing the release.
                    parameter_type: text
                    parameter_value: '_'
                AUTO_COMMIT_GIT_AUTHOR_EMAIL:
                    parameter_description: |
                        Specify author email for Git commits.
                        The value will be used with `--author` option for all Git commits made automatically.
                        Substring can be used if it is uniquely identifies author within existing commits.
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
                RELEASE_PIPELINE_DRY_RUN:
                    parameter_description: |
                        Specify whether it is a dry run for release or not.
                        For example, if set to `True`, tag is not created and pushed `origin`.
                    parameter_type: boolean
                    parameter_value: True

                SKIP_RELEASE_PIPELINE:
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
                - P-06-promotion-release_pipeline_passed
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

        {% set job_template_id = 'release_pipeline-reset_previous_build' %}
        06-02-{{ job_template_id }}:

            enabled: True

            send_email_notifications: False

            job_group_name: release_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            restrict_to_system_role:
                - salt_master_role

            skip_if_true: SKIP_RELEASE_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml
                06-01-release_pipeline-release_build: initial.release_pipeline.dynamic_build_descriptor.yaml

            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 06-03-release_pipeline-describe_repositories_state

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

        {% set job_template_id = 'release_pipeline-describe_repositories_state' %}
        06-03-{{ job_template_id }}:

            enabled: True

            job_group_name: release_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            restrict_to_system_role:
                - salt_master_role

            skip_if_true: SKIP_RELEASE_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml
                06-01-release_pipeline-release_build: initial.release_pipeline.dynamic_build_descriptor.yaml

            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 06-04-release_pipeline-create_build_branches

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

        {% set job_template_id = 'release_pipeline-create_build_branches' %}
        06-04-{{ job_template_id }}:

            enabled: True

            job_group_name: release_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            restrict_to_system_role:
                - salt_master_role

            skip_if_true: SKIP_RELEASE_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml
                06-01-release_pipeline-release_build: initial.release_pipeline.dynamic_build_descriptor.yaml

            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 06-05-release_pipeline-transfer_dynamic_build_descriptor

            job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
            job_config_data:
                # NOTE: We reuse `init_pipeline-create_build_branches` template.
                {% set job_template_id = 'init_pipeline-create_build_branches' %}
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

        {% set job_template_id = 'release_pipeline-transfer_dynamic_build_descriptor' %}
        06-05-{{ job_template_id }}:

            enabled: True

            job_group_name: release_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            restrict_to_system_role:
                - salt_master_role

            skip_if_true: SKIP_RELEASE_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml
                06-01-release_pipeline-release_build: initial.release_pipeline.dynamic_build_descriptor.yaml

            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 06-06-release_pipeline-tag_build

            job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
            job_config_data:
                # NOTE: We reuse `package_pipeline-transfer_dynamic_build_descriptor` template.
                {% set job_template_id = 'package_pipeline-transfer_dynamic_build_descriptor' %}
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

        {% set job_template_id = 'release_pipeline-tag_build' %}
        06-06-{{ job_template_id }}:

            enabled: True

            job_group_name: release_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            restrict_to_system_role:
                - salt_master_role

            skip_if_true: SKIP_RELEASE_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml
                06-01-release_pipeline-release_build: initial.release_pipeline.dynamic_build_descriptor.yaml

            parameterized_job_triggers:
                job_not_faild:
                    condition: UNSTABLE_OR_BETTER
                    trigger_jobs:
                        - 06-07-release_pipeline-merge_build

            job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
            job_config_data:
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

        {% set job_template_id = 'release_pipeline-merge_build' %}
        06-07-{{ job_template_id }}:

            enabled: True

            job_group_name: release_pipeline_group

            discard_old_builds:
                build_days: {{ discard_build_days }}
                build_num: {{ discard_build_num }}

            restrict_to_system_role:
                - salt_master_role

            skip_if_true: SKIP_RELEASE_PIPELINE

            skip_script_execution: {{ skip_script_execution }}

            input_fingerprinted_artifacts:
                01-01-init_pipeline-start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml
                06-01-release_pipeline-release_build: initial.release_pipeline.dynamic_build_descriptor.yaml

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

