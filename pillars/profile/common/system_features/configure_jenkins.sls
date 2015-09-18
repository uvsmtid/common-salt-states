
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set project_name = props['project_name'] %}
{% set profile_name = props['profile_name'] %}
{% set master_minion_id = props['master_minion_id'] %}
{% set use_pillars_from_states_repo = props['use_pillars_from_states_repo'] %}
{% set default_username = props['default_username'] %}

# Import `maven_repo_names`.
{% set maven_repo_names_path = profile_root.replace('.', '/') + '/common/system_maven_artifacts/maven_repo_names.yaml' %}
{% import_yaml maven_repo_names_path as maven_repo_names %}

{% set maven_job_name_prefix = 'build_repo' %}

system_features:

    # Jenkins configuration
    configure_jenkins:

        feature_enabled: True

        # Both of these port conflict with Maven integration tests
        # using Jboss when set to defaults (8080 and 8009).
        jenkins_http_port: 8088
        jenkins_ajp_port: 8089

        jenkins_root_dir: '/var/lib/jenkins'

        rewrite_jenkins_configuration_for_nodes: True
        rewrite_jenkins_configuration_for_jobs: True
        rewrite_jenkins_configuration_for_views: True

        # TODO: Jenkins does not support credentials management via CLI yet.
        #       Find a way to preconfigure keys to connect to the nodes.
        #       There is an issue that credentials are identified by their
        #       UUID. And because there could be various destination
        #       usernames per host, there is a need to be flexible and
        #       support multiple username credentials (even if key is
        #       the same).
        #
        # TODO: Review the following statement
        #       (as it seems to be automatic already).
        #
        # At the moment, simply disable connecting to the nodes as it should
        # be done manually:
        #   - Go to "Credentials" configuration, select:
        #       - "SSH Username with private key"
        #       - username: username
        #       - Private Key: "From the Jenkins master ~/.ssh"
        #   - Go to each slave node configuration, select:
        #       - Launch method: "Launch slave agents on Unix machines via SSH"
        #       - Host: nelskg1a
        #       - Credentials: username
        #   - Reconnect slave node.
        #
        make_sure_nodes_are_connected: False

        # See: docs/pillars/common/system_features/configure_jenkins/job_configs/readme.md
        job_configs:

        # Documetnation.
        #   _id:
        #       # docs/pillars/common/system_features/configure_jenkins/job_configs/_id/readme.md
        #
        #       timer_spec:
        #           # docs/pillars/common/system_features/configure_jenkins/job_configs/_id/timer_spec/readme.md
        #
        #       TODO: `trigger_jobs` is outdated, it is `parameterized_job_triggers` now
        #       trigger_jobs:
        #           # docs/pillars/common/system_features/configure_jenkins/job_configs/_id/trigger_jobs/readme.md
        #

            # If set to `-1`, keep forever.
            {% set discard_build_days = 7 %}
            {% set discard_build_num = 9 %}

            ###################################################################
            # The trigger is not supposed to be doing much.
            # Instead, it can be configured to start downstream job
            # on timer or on change (or on demand as always available).

            ###################################################################
            # The `init_pipeline`

            # TODO: At the moment this job is disabled.
            {% set job_template_id = 'init_pipeline.automatic_trigger' %}
            __.{{ job_template_id }}:

                enabled: False

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                # NOTE: This job is initial and not a parameterized.
                #       This environment variable won't be available.
                {% if False %}
                skip_if_true: SKIP_INIT_PIPELINE
                {% endif %}

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - 01.init_pipeline.start_new_build

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

            {% set skip_script_execution = False %}

            {% set job_template_id = 'init_pipeline.clean_old_build' %}
            __.{{ job_template_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_if_true: SKIP_INIT_PIPELINE

                is_standalone: True

                skip_script_execution: {{ skip_script_execution }}

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
                    # NOTE: This is the same job as `reset_previous_build`.
                    #       It just have different configuration.
                    {% set job_template_id = 'init_pipeline.reset_previous_build' %}
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

            {% set job_template_id = 'init_pipeline.start_new_build' %}
            01.{{ job_template_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_if_true: SKIP_INIT_PIPELINE

                skip_script_execution: {{ skip_script_execution }}

                archive_artifacts:
                    # NOTE: This is the file which fingerprint allows
                    #       associate all jobs in the pipelines together.
                    - initial.init_pipeline.dynamic_build_descriptor.yaml

                # NOTE: Even if we need to re-use this artifact from
                #       `init_pipeline.start_new_build` for association,
                #       the approach is to re-create this artifact
                #       (get from parent build) and archive it again instead
                #       of using Copy Artifact plugin.
                #       Because we re-use existing artifact, the fingerprint
                #       will be the same and association with
                #       `init_pipeline.start_new_build` will happen again.
                #       Why not using Copy Artifact plugin?
                #       Because this build is triggered manually and copying
                #       artifact would resort to the latest build of
                #       `init_pipeline.start_new_build` instead of
                #       continuing based on parent build. We want
                #       to set all branches to condition met in some
                #       build in the past. This can only be done by
                #       the job itself which takes parent build parameter.
                #       And we also have to archive another artefact which
                #       originates in this job so that promotion jobs can
                #       see associations of downstream jobs with this one.
                {% if False %}
                input_fingerprinted_artifacts:
                    01.init_pipeline.start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml
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
                            - 02.init_pipeline.reset_previous_build

                # NOTE: This job is promotable and uses another config.
                job_config_function_source: 'common/jenkins/configure_jobs_ext/promotable_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

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
                        parameter_type: string
                        parameter_value: '_'
                    UPDATE_REPOSITORIES:
                        parameter_description: |
                            This update branches from upstream repositories.
                            NOTE: If `USE_SOURCES_FROM_BUILD_TITLE` is set, this option is ignored.
                        parameter_type: boolean
                        parameter_value: True
                    PARENT_BUILD_TITLE:
                        parameter_description: |
                            Specify build title from existing history.
                            If this parameter is specified, then `init_pipeline.create_build_branches` job
                            sets HEADs of newly created build branches to `latest_commit_ids` from that build title;.
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
                    - 01.promotion.init_pipeline_passed
                    - 02.promotion.update_pipeline_passed
                    - 03.promotion.maven_pipeline_passed
                    - 04.promotion.deploy_pipeline_passed

                    - 05.promotion.package_pipeline_passed
                    - 06.promotion.release_pipeline_passed

                    - 07.promotion.bootstrap_package_approved

            {% set job_template_id = 'init_pipeline.reset_previous_build' %}
            02.{{ job_template_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_if_true: SKIP_INIT_PIPELINE

                skip_script_execution: {{ skip_script_execution }}

                input_fingerprinted_artifacts:
                    01.init_pipeline.start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - 03.init_pipeline.describe_repositories_state

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

            {% set job_template_id = 'init_pipeline.describe_repositories_state' %}
            03.{{ job_template_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_if_true: SKIP_INIT_PIPELINE

                skip_script_execution: {{ skip_script_execution }}

                input_fingerprinted_artifacts:
                    01.init_pipeline.start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - 04.init_pipeline.create_build_branches

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

            {% set job_template_id = 'init_pipeline.create_build_branches' %}
            04.{{ job_template_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_if_true: SKIP_INIT_PIPELINE

                skip_script_execution: {{ skip_script_execution }}

                input_fingerprinted_artifacts:
                    01.init_pipeline.start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml

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

            #------------------------------------------------------------------

            {% set job_template_id = 'promotion.init_pipeline_passed' %}
            01.{{ job_template_id }}:

                enabled: True

                is_promotion: True

                restrict_to_system_role:
                    - controller_role

                condition_job_list:
                    - 04.init_pipeline.create_build_branches

                condition_type: downstream_passed
                accept_unstable: True
                promotion_icon: star-blue

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - 21.update_pipeline.restart_master_salt_services

                job_config_function_source: 'common/jenkins/configure_jobs_ext/promotable_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/promotion.template.xml'

            {% set job_template_id = 'promotion.update_pipeline_passed' %}
            02.{{ job_template_id }}:

                enabled: True

                is_promotion: True

                restrict_to_system_role:
                    - controller_role

                condition_job_list:
                    - 24.update_pipeline.reconnect_jenkins_slaves

                condition_type: downstream_passed
                accept_unstable: True
                promotion_icon: star-purple

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - 31.maven_pipeline.maven_build_all

                job_config_function_source: 'common/jenkins/configure_jobs_ext/promotable_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/promotion.template.xml'

            {% set job_template_id = 'promotion.maven_pipeline_passed' %}
            03.{{ job_template_id }}:

                enabled: True

                is_promotion: True

                restrict_to_system_role:
                    - controller_role

                condition_job_list:
                    - 31.maven_pipeline.maven_build_all
                    {% for maven_repo_name in maven_repo_names %}
                    - 32.maven_pipeline.{{ maven_job_name_prefix }}.{{ maven_repo_name }}
                    {% endfor %}

                condition_type: downstream_passed
                accept_unstable: True
                promotion_icon: star-gold

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - 401.deploy_pipeline.register_generated_resources

                job_config_function_source: 'common/jenkins/configure_jobs_ext/promotable_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/promotion.template.xml'

            {% set job_template_id = 'promotion.deploy_pipeline_passed' %}
            04.{{ job_template_id }}:

                enabled: True

                is_promotion: True

                restrict_to_system_role:
                    - controller_role

                condition_job_list:
                    - 409.deploy_pipeline.run_salt_highstate

                # This is the last automatic pipeline -
                # `package_pipeline` and `release_pipeline` are
                # manually triggered.
                {% if False %}
                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            []
                {% endif %}

                condition_type: downstream_passed
                accept_unstable: True
                promotion_icon: star-green

                job_config_function_source: 'common/jenkins/configure_jobs_ext/promotable_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/promotion.template.xml'

            {% set job_template_id = 'promotion.package_pipeline_passed' %}
            05.{{ job_template_id }}:

                enabled: True

                is_promotion: True

                restrict_to_system_role:
                    - controller_role

                condition_job_list:
                    - 57.package_pipeline.store_bootstrap_package

                condition_type: downstream_passed
                accept_unstable: True
                promotion_icon: star-silver-e

                # The `package_pipeline` is manually triggered
                # and does not trigger any other pipelines.
                {% if False %}
                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            []
                {% endif %}

                job_config_function_source: 'common/jenkins/configure_jobs_ext/promotable_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/promotion.template.xml'

            {% set job_template_id = 'promotion.release_pipeline_passed' %}
            06.{{ job_template_id }}:

                enabled: True

                is_promotion: True

                restrict_to_system_role:
                    - controller_role

                condition_job_list:
                    - 61.release_pipeline.release_build

                condition_type: downstream_passed
                accept_unstable: True
                promotion_icon: star-red-e

                # The `release_pipeline` is manually triggered
                # and does not trigger any other pipelines.
                {% if False %}
                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            []
                {% endif %}

                job_config_function_source: 'common/jenkins/configure_jobs_ext/promotable_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/promotion.template.xml'

            {% set job_template_id = 'promotion.bootstrap_package_approved' %}
            07.{{ job_template_id }}:

                enabled: True

                is_promotion: True

                restrict_to_system_role:
                    - controller_role

                condition_type: manual_approval
                promotion_icon: star-orange-e

                job_config_function_source: 'common/jenkins/configure_jobs_ext/promotable_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/promotion.template.xml'

            ###################################################################
            # The `update_pipeline`

            {% set skip_script_execution = False %}

            {% set job_template_id = 'update_pipeline.restart_master_salt_services' %}
            21.{{ job_template_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_if_true: SKIP_UPDATE_PIPELINE

                skip_script_execution: {{ skip_script_execution }}

                input_fingerprinted_artifacts:
                    01.init_pipeline.start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - 22.update_pipeline.configure_jenkins_jobs

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

            {% set job_template_id = 'update_pipeline.configure_jenkins_jobs' %}
            22.{{ job_template_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_if_true: SKIP_UPDATE_PIPELINE

                skip_script_execution: {{ skip_script_execution }}

                input_fingerprinted_artifacts:
                    01.init_pipeline.start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - 23.update_pipeline.run_salt_highstate

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

            {% set job_template_id = 'update_pipeline.run_salt_highstate' %}
            23.{{ job_template_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_if_true: SKIP_UPDATE_PIPELINE

                skip_script_execution: {{ skip_script_execution }}

                input_fingerprinted_artifacts:
                    01.init_pipeline.start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - 24.update_pipeline.reconnect_jenkins_slaves

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

            {% set job_template_id = 'update_pipeline.reconnect_jenkins_slaves' %}
            24.{{ job_template_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                # NOTE: This job is special.
                #       While all other jobs run through Jenkins Slaves
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
                    01.init_pipeline.start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml

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

            ###################################################################
            # The `maven_pipeline`

            {% set skip_script_execution = False %}

            {% set job_template_id = 'maven_pipeline.maven_build_all' %}
            31.{{ job_template_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                # TODO: At the moment Maven jobs cannot be scipped.
                skip_if_true: SKIP_MAVEN_PIPELINE

                skip_script_execution: {{ skip_script_execution }}

                input_fingerprinted_artifacts:
                    01.init_pipeline.start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml

                parameterized_job_triggers:
                    build_always:
                        # NOTE: Try to build individual Maven jobs
                        #       to update their status as well.
                        condition: ALWAYS
                        trigger_jobs:
                            {% for maven_repo_name in maven_repo_names %}
                            - 32.maven_pipeline.{{ maven_job_name_prefix }}.{{ maven_repo_name }}
                            {% endfor %}

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

                # Instead of join, use promotion to trigger next pipeline.
                # Otherwise, the Build Pipeline View cannot handle join
                # and draws duplicated chains after each job to be joined.
                {% if False %}
                trigger_jobs_on_downstream_join:
                    - 401.deploy_pipeline.register_generated_resources
                {% endif %}

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    # NOTE: This job is simply a Maven build which uses
                    # special `pom.xml` from parent repository which
                    # spans all components by referencing them as modules.
                    xml_config_template: 'common/jenkins/configure_jobs_ext/maven_pipeline.maven_project_job.xml'
                    repository_name: 'maven-demo'
                    component_pom_path: 'pom.xml'

                disable_archiving: True

            {% for maven_repo_name in maven_repo_names %}

            32.maven_pipeline.{{ maven_job_name_prefix }}.{{ maven_repo_name }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - jenkins_slave_role

                # TODO: At the moment Maven jobs cannot be scipped.
                skip_if_true: SKIP_MAVEN_PIPELINE

                skip_script_execution: {{ skip_script_execution }}

                input_fingerprinted_artifacts:
                    01.init_pipeline.start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/maven_pipeline.maven_project_job.xml'
                    repository_name: {{ maven_repo_name }}

                # Some repositories do not have `pom.xml` in default location.
                # Note that at the moment all repo's roots
                # were supplied with pom.xml.
                {% if not maven_repo_name %}
                    {{ FAIL_here }}
                {% else %}
                    component_pom_path: 'pom.xml'
                {% endif %}

                disable_archiving: True

                # This is the final job in the pipeline.
                {% if False %}
                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            []
                {% endif %}

            {% endfor %}

            ###################################################################
            # The `deploy_pipeline`

            {% set skip_script_execution = False %}

            {% set job_template_id = 'deploy_pipeline.register_generated_resources' %}
            401.{{ job_template_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_if_true: SKIP_DEPLOY_PIPELINE

                skip_script_execution: {{ skip_script_execution }}

                input_fingerprinted_artifacts:
                    01.init_pipeline.start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - 402.deploy_pipeline.transfer_dynamic_build_descriptor

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    # NOTE: It is project-specific job configuration.
                    {% if project_name == 'common' %}
                    # This is a template.
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'
                    {% else %}
                    xml_config_template: '{{ project_name }}/jenkins/job_configurations/{{ job_template_id }}.xml'
                    {% endif %}

            {% set job_template_id = 'deploy_pipeline.transfer_dynamic_build_descriptor' %}
            402.{{ job_template_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_if_true: SKIP_DEPLOY_PIPELINE

                skip_script_execution: {{ skip_script_execution }}

                input_fingerprinted_artifacts:
                    01.init_pipeline.start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - 403.deploy_pipeline.build_bootstrap_package

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    # NOTE: This job cloned from `package_pipeline`.
                    {% set job_template_id = 'package_pipeline.transfer_dynamic_build_descriptor' %}
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

            {% set job_template_id = 'deploy_pipeline.build_bootstrap_package' %}
            403.{{ job_template_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_if_true: SKIP_DEPLOY_PIPELINE

                skip_script_execution: {{ skip_script_execution }}

                input_fingerprinted_artifacts:
                    01.init_pipeline.start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - 404.deploy_pipeline.configure_vagrant

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    # NOTE: This job cloned from `package_pipeline`.
                    {% set job_template_id = 'package_pipeline.build_bootstrap_package' %}
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

            {% set job_template_id = 'deploy_pipeline.configure_vagrant' %}
            404.{{ job_template_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_if_true: SKIP_DEPLOY_PIPELINE

                skip_script_execution: {{ skip_script_execution }}

                input_fingerprinted_artifacts:
                    01.init_pipeline.start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - 405.deploy_pipeline.destroy_vagrant_hosts

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

            {% set job_template_id = 'deploy_pipeline.destroy_vagrant_hosts' %}
            405.{{ job_template_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_if_true: SKIP_DEPLOY_PIPELINE

                skip_script_execution: {{ skip_script_execution }}

                input_fingerprinted_artifacts:
                    01.init_pipeline.start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - 406.deploy_pipeline.remove_salt_minion_keys

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

            {% set job_template_id = 'deploy_pipeline.remove_salt_minion_keys' %}
            406.{{ job_template_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_if_true: SKIP_DEPLOY_PIPELINE

                skip_script_execution: {{ skip_script_execution }}

                input_fingerprinted_artifacts:
                    01.init_pipeline.start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - 407.deploy_pipeline.instantiate_vagrant_hosts

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

            {% set job_template_id = 'deploy_pipeline.instantiate_vagrant_hosts' %}
            407.{{ job_template_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_if_true: SKIP_DEPLOY_PIPELINE

                skip_script_execution: {{ skip_script_execution }}

                input_fingerprinted_artifacts:
                    01.init_pipeline.start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - 408.deploy_pipeline.run_salt_orchestrate

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

            {% set job_template_id = 'deploy_pipeline.run_salt_orchestrate' %}
            408.{{ job_template_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_if_true: SKIP_DEPLOY_PIPELINE

                skip_script_execution: {{ skip_script_execution }}

                input_fingerprinted_artifacts:
                    01.init_pipeline.start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - 409.deploy_pipeline.run_salt_highstate

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

            {% set job_template_id = 'deploy_pipeline.run_salt_highstate' %}
            409.{{ job_template_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_if_true: SKIP_DEPLOY_PIPELINE

                skip_script_execution: {{ skip_script_execution }}

                input_fingerprinted_artifacts:
                    01.init_pipeline.start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml

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

            ###################################################################
            # The `package_pipeline`

            {% set skip_script_execution = False %}

            {% set job_template_id = 'package_pipeline.create_new_package' %}
            51.{{ job_template_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_if_true: SKIP_PACKAGE_PIPELINE

                skip_script_execution: {{ skip_script_execution }}

                archive_artifacts:
                    # NOTE: We re-archive the same file which is
                    #       restored from parent build.
                    - initial.init_pipeline.dynamic_build_descriptor.yaml
                    - initial.package_pipeline.dynamic_build_descriptor.yaml

                # NOTE: Even if we need to re-use this artifact from
                #       `init_pipeline.start_new_build` for association,
                #       the approach is to re-create this artifact
                #       (get from parent build) and archive it again instead
                #       of using Copy Artifact plugin
                #       (see `archive_artifacts`).
                #       Because we re-use existing artifact, the fingerprint
                #       will be the same and association with
                #       `init_pipeline.start_new_build` will happen again.
                #       Why not using Copy Artifact plugin?
                #       Because this build is triggered manually and copying
                #       artifact would resort to the latest build of
                #       `init_pipeline.start_new_build` instead of
                #       continuing based on parent build. We want
                #       to set all branches to condition met in some
                #       build in the past. This can only be done by
                #       the job itself which takes parent build parameter.
                #       And we also have to archive another artefact which
                #       originates in this job so that promotion jobs can
                #       see associations of downstream jobs with this one.
                {% if False %}
                input_fingerprinted_artifacts:
                    01.init_pipeline.start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml
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
                            - 52.package_pipeline.reset_previous_build

                # NOTE: This job is promotable and uses another config.
                job_config_function_source: 'common/jenkins/configure_jobs_ext/promotable_xml_template_job.sls'
                job_config_data:
                    # NOTE: We reuse `init_pipeline.start_new_build` template.
                    {% set job_template_id = 'init_pipeline.start_new_build' %}
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

                build_parameters:
                    TARGET_PROFILE_NAME:
                        parameter_description: |
                            Specify target profile for bootstrap package.
                            It is embedded into build title.
                            Note that SOURCE_PROFILE is determined automatically.
                        parameter_type: choice
                        parameter_value:
                            {% for target_profile_name in props['load_bootstrap_target_envs'].keys() %}
                            - {{ target_profile_name }}
                            {% endfor %}
                            - {{ profile_name }}
                    BUILD_LABEL:
                        parameter_description: |
                            Short meaningful string to differentiate this build.
                            It is embedded into package title.
                            TODO: Should it be named `PACKAGE_LABEL`?
                        parameter_type: string
                        parameter_value: '_'
                    BUILD_NOTES:
                        parameter_description: |
                            Any notes describing the build.
                            TODO: Should it be named `PACKAGE_NOTES`?
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
                            If this parameter is specified, then `init_pipeline.create_build_branches` job
                            sets HEADs of newly created build branches to `latest_commit_ids` from that build title;.
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

                use_promotions:
                    - 05.promotion.package_pipeline_passed
                    - 07.promotion.bootstrap_package_approved

            {% set job_template_id = 'package_pipeline.reset_previous_build' %}
            52.{{ job_template_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_if_true: SKIP_INIT_PIPELINE

                skip_script_execution: {{ skip_script_execution }}

                input_fingerprinted_artifacts:
                    01.init_pipeline.start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml
                    51.package_pipeline.create_new_package: initial.package_pipeline.dynamic_build_descriptor.yaml

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - 53.package_pipeline.describe_repositories_state

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    # NOTE: We reuse `init_pipeline.reset_previous_build` template.
                    {% set job_template_id = 'init_pipeline.reset_previous_build' %}
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

            {% set job_template_id = 'package_pipeline.describe_repositories_state' %}
            53.{{ job_template_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_if_true: SKIP_INIT_PIPELINE

                skip_script_execution: {{ skip_script_execution }}

                input_fingerprinted_artifacts:
                    01.init_pipeline.start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml
                    51.package_pipeline.create_new_package: initial.package_pipeline.dynamic_build_descriptor.yaml

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - 54.package_pipeline.create_build_branches

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    # NOTE: We reuse `init_pipeline.describe_repositories_state` template.
                    {% set job_template_id = 'init_pipeline.describe_repositories_state' %}
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

            {% set job_template_id = 'package_pipeline.create_build_branches' %}
            54.{{ job_template_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_if_true: SKIP_INIT_PIPELINE

                skip_script_execution: {{ skip_script_execution }}

                input_fingerprinted_artifacts:
                    01.init_pipeline.start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml
                    51.package_pipeline.create_new_package: initial.package_pipeline.dynamic_build_descriptor.yaml

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - 55.package_pipeline.transfer_dynamic_build_descriptor

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    # NOTE: We reuse `init_pipeline.create_build_branches` template.
                    {% set job_template_id = 'init_pipeline.create_build_branches' %}
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

            {% set job_template_id = 'package_pipeline.transfer_dynamic_build_descriptor' %}
            55.{{ job_template_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_if_true: SKIP_PACKAGE_PIPELINE

                skip_script_execution: {{ skip_script_execution }}

                input_fingerprinted_artifacts:
                    01.init_pipeline.start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml
                    51.package_pipeline.create_new_package: initial.package_pipeline.dynamic_build_descriptor.yaml

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - 56.package_pipeline.build_bootstrap_package

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

            {% set job_template_id = 'package_pipeline.build_bootstrap_package' %}
            56.{{ job_template_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_if_true: SKIP_PACKAGE_PIPELINE

                skip_script_execution: {{ skip_script_execution }}

                input_fingerprinted_artifacts:
                    01.init_pipeline.start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml
                    51.package_pipeline.create_new_package: initial.package_pipeline.dynamic_build_descriptor.yaml

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - 57.package_pipeline.store_bootstrap_package

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

            {% set job_template_id = 'package_pipeline.store_bootstrap_package' %}
            57.{{ job_template_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_if_true: SKIP_PACKAGE_PIPELINE

                skip_script_execution: {{ skip_script_execution }}

                input_fingerprinted_artifacts:
                    01.init_pipeline.start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml
                    51.package_pipeline.create_new_package: initial.package_pipeline.dynamic_build_descriptor.yaml

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

            ###################################################################
            # The `release_pipeline`

            {% set skip_script_execution = False %}

            {% set job_template_id = 'release_pipeline.release_build' %}
            61.{{ job_template_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_if_true: SKIP_RELEASE_PIPELINE

                skip_script_execution: {{ skip_script_execution }}

                archive_artifacts:
                    # NOTE: We re-archive the same file which is
                    #       restored from parent build.
                    - initial.init_pipeline.dynamic_build_descriptor.yaml
                    - initial.release_pipeline.dynamic_build_descriptor.yaml

                # NOTE: Even if we need to re-use this artifact from
                #       `init_pipeline.start_new_build` for association,
                #       the approach is to re-create this artifact
                #       (get from parent build) and archive it again instead
                #       of using Copy Artifact plugin.
                #       Because we re-use existing artifact, the fingerprint
                #       will be the same and association with
                #       `init_pipeline.start_new_build` will happen again.
                #       Why not using Copy Artifact plugin?
                #       Because this build is triggered manually and copying
                #       artifact would resort to the latest build of
                #       `init_pipeline.start_new_build` instead of
                #       continuing based on parent build. We want
                #       to set all branches to condition met in some
                #       build in the past. This can only be done by
                #       the job itself which takes parent build parameter.
                #       And we also have to archive another artefact which
                #       originates in this job so that promotion jobs can
                #       see associations of downstream jobs with this one.
                {% if False %}
                input_fingerprinted_artifacts:
                    01.init_pipeline.start_new_build: initial.init_pipeline.dynamic_build_descriptor.yaml
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

                # TODO: Implement.
                #       This is the first and the final job at the moment.
                {% if False %}
                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            []
                {% endif %}

                # NOTE: This job is promotable and uses another config.
                job_config_function_source: 'common/jenkins/configure_jobs_ext/promotable_xml_template_job.sls'
                job_config_data:
                    # NOTE: We reuse `init_pipeline.start_new_build` template.
                    {% set job_template_id = 'init_pipeline.start_new_build' %}
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_template_id }}.xml'

                build_parameters:
                    RELEASE_TYPE:
                        parameter_description: |
                            Release types affect versioning and tagging.
                            It is embedded into release title.
                        parameter_type: choice
                        parameter_value:
                            - INCREMENTAL_RELEASE
                            - SEMANTIC_RELEASE
                    RELEASE_VERSION_NUMBER:
                        parameter_description: |
                            Version number should have format `X.Y.Z.N`.
                            It is embedded into release title.
                        parameter_type: string
                        parameter_value: '_'
                    BUILD_LABEL:
                        parameter_description: |
                            Short meaningful string to differentiate this build.
                            It is embedded into package title.
                            TODO: Should it be named `RELEASE_LABEL`?
                        parameter_type: string
                        parameter_value: '_'
                    BUILD_NOTES:
                        parameter_description: |
                            Any notes describing the build.
                            TODO: Should it be named `RELEASE_NOTES`?
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
                            If this parameter is specified, then `init_pipeline.create_build_branches` job
                            sets HEADs of newly created build branches to `latest_commit_ids` from that build title;.
                            NOTE: The new build will have its own build title (and build branch names).
                            This is just a mechanism to reuse state of the build from the past
                            (for example, for release, packaging, or re-building).
                            The build title can be found in dynamic build descriptor in the value of `build_title` key.
                        parameter_type: string
                        parameter_value: '_'

                    SKIP_RELEASE_PIPELINE:
                        parameter_description: |
                            TODO: Quick and dirty impl to skip pipeline.
                        parameter_type: boolean
                        parameter_value: False

                use_promotions:
                    - 06.promotion.release_pipeline_passed

        #######################################################################
        #

        view_configs:

            0.triggers:

                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/list_view.xml'

                    job_list:
                        - __.init_pipeline.automatic_trigger
                        - __.init_pipeline.clean_old_build
                        - 01.init_pipeline.start_new_build
                        - 51.package_pipeline.create_new_package
                        - 61.release_pipeline.release_build

            {% if False %} # DISABLED: Not so useful list.
            maven:

                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/list_view.xml'

                    job_list:
                        - 31.maven_pipeline.maven_build_all
                        {% for maven_repo_name in maven_repo_names %}
                        - 32.maven_pipeline.{{ maven_job_name_prefix }}.{{ maven_repo_name }}
                        {% endfor %}
            {% endif %}

            1.init_pipeline:

                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/build_pipeline_view.xml'

                    first_job_name: 01.init_pipeline.start_new_build

            2.update_pipeline:

                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/build_pipeline_view.xml'

                    first_job_name: 21.update_pipeline.restart_master_salt_services

            3.maven_pipeline:

                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/build_pipeline_view.xml'

                    first_job_name: 31.maven_pipeline.maven_build_all

            4.deploy_pipeline:

                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/build_pipeline_view.xml'

                    first_job_name: 401.deploy_pipeline.register_generated_resources

            5.package_pipeline:

                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/build_pipeline_view.xml'

                    first_job_name: 51.package_pipeline.create_new_package

            6.release_pipeline:

                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/build_pipeline_view.xml'

                    first_job_name: 61.release_pipeline.release_build

###############################################################################
# EOF
###############################################################################

