
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
{% set current_task_branch = props['current_task_branch'] %}

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
            # Set of trigger-jobs which are not supposed to be doing much.
            # They are only used to trigger downstram jobs.

            # NOTE: At the moment this job simply refers to another
            #       `auto_pipeline.update_salt_master_sources` job without actually
            #       executing it (see `skip_script_execution`).
            {% set job_id = 'trigger_on_demand' %}
            {{ job_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - auto_pipeline.update_salt_master_sources

                skip_script_execution: True

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/auto_pipeline.update_salt_master_sources.xml'

            # NOTE: At the moment this job simply tries to do what
            #       `auto_pipeline.update_salt_master_sources` does but it skips
            #       any updates (see `skip_script_execution`) and does it
            #       on a timely basis.
            {% set job_id = 'trigger_on_timer' %}
            {{ job_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                # Disable timer trigger.
                #{#
                timer_spec: 'H */2 * * *'
                #}#

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - auto_pipeline.update_salt_master_sources

                skip_script_execution: True

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/auto_pipeline.update_salt_master_sources.xml'

            # TODO: At the moment this job simply tries to do what
            #       `auto_pipeline.update_salt_master_sources` does but it does trigger
            #       pipeline even if there is no changes.
            {% set job_id = 'trigger_on_changes' %}
            {{ job_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - auto_pipeline.update_salt_master_sources

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/auto_pipeline.update_salt_master_sources.xml'

            ###################################################################
            # The `auto_pipeline`

            {% set job_id = 'auto_pipeline.update_salt_master_sources' %}
            {{ job_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - init_pipeline.start_new_build

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            ###################################################################
            # The `init_pipeline`

            {% set skip_script_execution = False %}

            {% set job_id = 'init_pipeline.clean_old_build' %}
            {{ job_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

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
                    {% set job_id = 'init_pipeline.reset_previous_build' %}
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            {% set job_id = 'init_pipeline.start_new_build' %}
            {{ job_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_script_execution: {{ skip_script_execution }}

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - init_pipeline.reset_previous_build

                job_config_function_source: 'common/jenkins/configure_jobs_ext/promotable_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

                build_parameters:
                    BUILD_LABEL:
                        parameter_description: |
                            Short meaningful string to differentiate this build.
                            It is embedded into build title.
                        parameter_type: string
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
                    GIT_AUTHOR_EMAIL:
                        parameter_description: |
                            Specify author email for Git commits.
                            The value will be used with `--author` option for all Git commits made automatically.
                            Substring can be used if it is uniquely identifies author within existing commits.
                        parameter_type: string
                        parameter_value: '_'
                    BUILD_NOTES:
                        parameter_description: |
                            Any notes describing the build.
                        parameter_type: text
                        parameter_value: '_'
                    REMOVE_BUILD_BRANCHES_AFTER_PIPELINE_COMPLETION:
                        parameter_description: |
                            This causes all build branches to be removed in the last job.
                            TODO: Fail build if this is set for for `INCREMENTAL_RELEASE` or `SEMANTIC_RELEASE` build type without tagging.
                            TODO: Build branches should be automatically removed if previous build was unsuccessful.
                        parameter_type: boolean
                        parameter_value: True
                    USE_SOURCES_FROM_BUILD_TITLE:
                        parameter_description: |
                            Specify build title from existing history.
                            If this parameter is specified, it restores sources to `restore_point_commit_ids` of the specified build title.
                            This is just a mechanism to rebuild something as it was in the past.
                            The build title can be found in dynamic build descriptor in the value of `build_title` key.
                            TODO: Not implemented yet.
                        parameter_type: string
                        parameter_value: '_'

                use_promotions:
                    - promotion.init_pipeline_passed
                    - promotion.update_pipeline_passed
                    - promotion.maven_pipeline_passed
                    - promotion.deploy_pipeline_passed

                    - promotion.package_pipeline_passed
                    - promotion.release_pipeline_passed
                    - promotion.bootstrap_package_approved

            {% set job_id = 'init_pipeline.reset_previous_build' %}
            {{ job_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_script_execution: {{ skip_script_execution }}

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - init_pipeline.describe_repositories_state

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            {% set job_id = 'init_pipeline.describe_repositories_state' %}
            {{ job_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_script_execution: {{ skip_script_execution }}

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - init_pipeline.create_build_branches

                job_config_function_source: 'common/jenkins/configure_jobs_ext/promotable_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            {% set job_id = 'init_pipeline.create_build_branches' %}
            {{ job_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_script_execution: {{ skip_script_execution }}

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
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            {% set job_id = 'init_pipeline.complete_build' %}
            {{ job_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_script_execution: {{ skip_script_execution }}

                # The job is supposed to be started
                # after all all pipelines finish as the final step.
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
                    {% set job_id = 'init_pipeline.reset_previous_build' %}
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            #------------------------------------------------------------------

            {% set job_id = 'promotion.init_pipeline_passed' %}
            {{ job_id }}:

                enabled: True

                is_promotion: True

                restrict_to_system_role:
                    - controller_role

                condition_job_list:
                    - init_pipeline.create_build_branches

                condition_type: downstream_passed
                accept_unstable: True
                promotion_icon: star-blue

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - update_pipeline.restart_master_salt_services

                job_config_function_source: 'common/jenkins/configure_jobs_ext/promotable_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/promotion.template.xml'

            {% set job_id = 'promotion.update_pipeline_passed' %}
            {{ job_id }}:

                enabled: True

                is_promotion: True

                restrict_to_system_role:
                    - controller_role

                condition_job_list:
                    - update_pipeline.reconnect_jenkins_slaves

                condition_type: downstream_passed
                accept_unstable: True
                promotion_icon: star-purple

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - maven_pipeline.maven_build_all

                job_config_function_source: 'common/jenkins/configure_jobs_ext/promotable_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/promotion.template.xml'

            {% set job_id = 'promotion.maven_pipeline_passed' %}
            {{ job_id }}:

                enabled: True

                is_promotion: True

                restrict_to_system_role:
                    - controller_role

                condition_job_list:
                    - maven_pipeline.maven_build_all
                    {% for maven_repo_name in maven_repo_names %}
                    - maven_pipeline.{{ maven_job_name_prefix }}.{{ maven_repo_name }}
                    {% endfor %}

                condition_type: downstream_passed
                accept_unstable: True
                promotion_icon: star-gold

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - deploy_pipeline.register_generated_resources

                job_config_function_source: 'common/jenkins/configure_jobs_ext/promotable_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/promotion.template.xml'

            {% set job_id = 'promotion.deploy_pipeline_passed' %}
            {{ job_id }}:

                enabled: True

                is_promotion: True

                restrict_to_system_role:
                    - controller_role

                condition_job_list:
                    - deploy_pipeline.run_salt_highstate

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

            {% set job_id = 'promotion.package_pipeline_passed' %}
            {{ job_id }}:

                enabled: True

                is_promotion: True

                restrict_to_system_role:
                    - controller_role

                condition_job_list:
                    - package_pipeline.build_bootstrap_package

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

            {% set job_id = 'promotion.release_pipeline_passed' %}
            {{ job_id }}:

                enabled: True

                is_promotion: True

                restrict_to_system_role:
                    - controller_role

                condition_job_list:
                    - release_pipeline.release_build

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

            {% set job_id = 'promotion.bootstrap_package_approved' %}
            {{ job_id }}:

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

            {% set job_id = 'update_pipeline.restart_master_salt_services' %}
            {{ job_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_script_execution: {{ skip_script_execution }}

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - update_pipeline.configure_jenkins_jobs

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            {% set job_id = 'update_pipeline.configure_jenkins_jobs' %}
            {{ job_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_script_execution: {{ skip_script_execution }}

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - update_pipeline.run_salt_highstate

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            {% set job_id = 'update_pipeline.run_salt_highstate' %}
            {{ job_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_script_execution: {{ skip_script_execution }}

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - update_pipeline.reconnect_jenkins_slaves

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            {% set job_id = 'update_pipeline.reconnect_jenkins_slaves' %}
            {{ job_id }}:

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

                skip_script_execution: {{ skip_script_execution }}

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
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            ###################################################################
            # The `maven_pipeline`

            {% set skip_script_execution = False %}

            {% set job_id = 'maven_pipeline.maven_build_all' %}
            {{ job_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_script_execution: {{ skip_script_execution }}

                parameterized_job_triggers:
                    build_always:
                        # NOTE: Try to build individual Maven jobs
                        #       to update their status as well.
                        condition: ALWAYS
                        trigger_jobs:
                            {% for maven_repo_name in maven_repo_names %}
                            - maven_pipeline.{{ maven_job_name_prefix }}.{{ maven_repo_name }}
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
                    - deploy_pipeline.register_generated_resources
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

            maven_pipeline.{{ maven_job_name_prefix }}.{{ maven_repo_name }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - jenkins_slave_role

                skip_script_execution: {{ skip_script_execution }}

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

            {% set job_id = 'deploy_pipeline.register_generated_resources' %}
            {{ job_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_script_execution: {{ skip_script_execution }}

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - deploy_pipeline.build_bootstrap_package

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    # NOTE: It is project-specific job configuration.
                    {% if project_name == 'common' %}
                    # This is a template.
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'
                    {% else %}
                    xml_config_template: '{{ project_name }}/jenkins/job_configurations/{{ job_id }}.xml'
                    {% endif %}

            {% set job_id = 'deploy_pipeline.transfer_dynamic_build_descriptor' %}
            {{ job_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_script_execution: {{ skip_script_execution }}

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - deploy_pipeline.transfer_dynamic_build_descriptor

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    # NOTE: This job cloned from `package_pipeline`.
                    {% set job_id = 'package_pipeline.transfer_dynamic_build_descriptor' %}
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            {% set job_id = 'deploy_pipeline.build_bootstrap_package' %}
            {{ job_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_script_execution: {{ skip_script_execution }}

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - deploy_pipeline.configure_vagrant

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    # NOTE: This job cloned from `package_pipeline`.
                    {% set job_id = 'package_pipeline.build_bootstrap_package' %}
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            {% set job_id = 'deploy_pipeline.configure_vagrant' %}
            {{ job_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_script_execution: {{ skip_script_execution }}

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - deploy_pipeline.destroy_vagrant_hosts

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            {% set job_id = 'deploy_pipeline.destroy_vagrant_hosts' %}
            {{ job_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_script_execution: {{ skip_script_execution }}

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - deploy_pipeline.remove_salt_minion_keys

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            {% set job_id = 'deploy_pipeline.remove_salt_minion_keys' %}
            {{ job_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_script_execution: {{ skip_script_execution }}

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - deploy_pipeline.instantiate_vagrant_hosts

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            {% set job_id = 'deploy_pipeline.instantiate_vagrant_hosts' %}
            {{ job_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_script_execution: {{ skip_script_execution }}

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - deploy_pipeline.run_salt_orchestrate

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            {% set job_id = 'deploy_pipeline.run_salt_orchestrate' %}
            {{ job_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_script_execution: {{ skip_script_execution }}

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - deploy_pipeline.run_salt_highstate

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            {% set job_id = 'deploy_pipeline.run_salt_highstate' %}
            {{ job_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_script_execution: {{ skip_script_execution }}

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
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            ###################################################################
            # The `package_pipeline`

            {% set skip_script_execution = False %}

            {% set job_id = 'package_pipeline.create_new_package' %}
            {{ job_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_script_execution: {{ skip_script_execution }}

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - package_pipeline.transfer_dynamic_build_descriptor

                job_config_function_source: 'common/jenkins/configure_jobs_ext/promotable_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

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
                    GIT_AUTHOR_EMAIL:
                        parameter_description: |
                            Specify author email for Git commits.
                            The value will be used with `--author` option for all Git commits made automatically.
                            Substring can be used if it is uniquely identifies author within existing commits.
                        parameter_type: string
                        parameter_value: '_'
                    BOOTSTRAP_PACKAGE_NOTES:
                        parameter_description: |
                            Any notes describing the build.
                        parameter_type: text
                        parameter_value: '_'
                    BUILD_TITLE:
                        parameter_description: |
                            TODO: Not implemented yet.
                            The build title can be found in dynamic build descriptor in the value of `build_title` key.
                        parameter_type: string
                        parameter_value: '_'

            {% set job_id = 'package_pipeline.transfer_dynamic_build_descriptor' %}
            {{ job_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_script_execution: {{ skip_script_execution }}

                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            - package_pipeline.build_bootstrap_package

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            {% set job_id = 'package_pipeline.build_bootstrap_package' %}
            {{ job_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_script_execution: {{ skip_script_execution }}

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
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            ###################################################################
            # The `release_pipeline`

            {% set skip_script_execution = False %}

            {% set job_id = 'release_pipeline.release_build' %}
            {{ job_id }}:

                enabled: True

                discard_old_builds:
                    build_days: {{ discard_build_days }}
                    build_num: {{ discard_build_num }}

                restrict_to_system_role:
                    - controller_role

                skip_script_execution: {{ skip_script_execution }}

                # TODO: Implement.
                #       This is the first and the final job at the moment.
                {% if False %}
                parameterized_job_triggers:
                    job_not_faild:
                        condition: UNSTABLE_OR_BETTER
                        trigger_jobs:
                            []
                {% endif %}

                job_config_function_source: 'common/jenkins/configure_jobs_ext/promotable_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

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
                    RELEASE_LABEL:
                        parameter_description: |
                            Short meaningful string to differentiate this release.
                            It is embedded into release title.
                        parameter_type: string
                        parameter_value: '_'
                    GIT_AUTHOR_EMAIL:
                        parameter_description: |
                            Specify author email for Git commits.
                            The value will be used with `--author` option for all Git commits made automatically.
                            Substring can be used if it is uniquely identifies author within existing commits.
                        parameter_type: string
                        parameter_value: '_'
                    RELEASE_NOTES:
                        parameter_description: |
                            Any notes describing the release.
                        parameter_type: text
                        parameter_value: '_'
                    BUILD_TITLE:
                        parameter_description: |
                            TODO: Not implemented yet.
                            The build title can be found in dynamic build descriptor in the value of `build_title` key.
                        parameter_type: string
                        parameter_value: '_'

        #######################################################################
        #

        view_configs:

            0.triggers:

                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/list_view.xml'

                    job_list:
                        - trigger_on_demand
                        - trigger_on_timer
                        - trigger_on_changes
                        - auto_pipeline.update_salt_master_sources
                        - init_pipeline.clean_old_build
                        - init_pipeline.start_new_build
                        - package_pipeline.create_new_package
                        - release_pipeline.release_build

            {% if False %} # DISABLED: Not so useful list.
            maven:

                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/list_view.xml'

                    job_list:
                        - maven_pipeline.maven_build_all
                        {% for maven_repo_name in maven_repo_names %}
                        - maven_pipeline.{{ maven_job_name_prefix }}.{{ maven_repo_name }}
                        {% endfor %}
            {% endif %}

            1.init_pipeline:

                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/build_pipeline_view.xml'

                    first_job_name: init_pipeline.start_new_build

            2.update_pipeline:

                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/build_pipeline_view.xml'

                    first_job_name: update_pipeline.restart_master_salt_services

            3.maven_pipeline:

                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/build_pipeline_view.xml'

                    first_job_name: maven_pipeline.maven_build_all

            4.deploy_pipeline:

                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/build_pipeline_view.xml'

                    first_job_name: deploy_pipeline.register_generated_resources

            5.package_pipeline:

                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/build_pipeline_view.xml'

                    first_job_name: package_pipeline.create_new_package

            6.release_pipeline:

                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/build_pipeline_view.xml'

                    first_job_name: release_pipeline.release_build

###############################################################################
# EOF
###############################################################################

