
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

        # Build branch name.
        # Jenkins expects this branch in repositories.
        # This branch is supposed to be set to what is supposed to be built.
        build_branch_name: next_build

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

        # Documetnation.
        #   _id:
        #       # docs/pillars/common/system_tasks/jenkins_tasks/_id/readme.md
        #
        #       timer_spec:
        #           # docs/pillars/common/system_tasks/jenkins_tasks/_id/timer_spec/readme.md
        #
        #       TODO: `trigger_jobs` is outdated, it is `parameterized_job_triggers` now
        #       trigger_jobs:
        #           # docs/pillars/common/system_tasks/jenkins_tasks/_id/trigger_jobs/readme.md
        #

        view_configs:

            +.triggers:

                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/list_view.xml'

                    job_list:
                        - __-__-init_pipeline-clean_old_build
                        - __-__-poll_pipeline-propose_build
                        - 00-01-poll_pipeline-verify_approval
                        - 01-01-init_pipeline-start_new_build
                        - 05-01-package_pipeline-create_new_package
                        - 06-01-release_pipeline-release_build
                        - 07-01-checkout_pipeline-checkout_build_branches

            {% if False %} # DISABLED: Not so useful list.
            maven:

                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/list_view.xml'

                    job_list:
                        - 03-01-maven_pipeline-maven_build_all
                        - 03-02-maven_pipeline-verify_maven_data
                        {% for maven_repo_name in maven_repo_names %}
                        - 03-03-maven_pipeline-{{ maven_job_name_prefix }}-{{ maven_repo_name }}
                        {% endfor %}
            {% endif %}

            00-poll_pipeline:

                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/build_pipeline_view.xml'

                    first_job_name: 00-01-poll_pipeline-verify_approval

            01-init_pipeline:

                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/build_pipeline_view.xml'

                    first_job_name: 01-01-init_pipeline-start_new_build

            02-update_pipeline:

                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/build_pipeline_view.xml'

                    first_job_name: 02-01-update_pipeline-restart_master_salt_services

            03-maven_pipeline:

                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/build_pipeline_view.xml'

                    first_job_name: 03-01-maven_pipeline-maven_build_all

            04-deploy_pipeline:

                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/build_pipeline_view.xml'

                    first_job_name: 04-01-deploy_pipeline-register_generated_resources

            05-package_pipeline:

                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/build_pipeline_view.xml'

                    first_job_name: 05-01-package_pipeline-create_new_package

            06-release_pipeline:

                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/build_pipeline_view.xml'

                    first_job_name: 06-01-release_pipeline-release_build

            07-checkout_pipeline:

                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/build_pipeline_view.xml'

                    first_job_name: 07-01-checkout_pipeline-checkout_build_branches

        #######################################################################
        #

        job_group_configs:

            # The lower the priority number the higher the priority.

            # This group exists simply to shift `group_id`
            # to match `priority_value`.
            unused_group:
                group_id: 0
                # Set the lowest priority (the largest number).
                priority_value: 1000

            #------------------------------------------------------------------
            # Default priority is the highest and used by majority of jobs.
            # This means that normal jobs has to complete before
            # other can be started.
            # If no `job_group_name` key is set in job configuration,
            # `default_group` is used.

            default_group:
                group_id: 1
                priority_value: 1

            #------------------------------------------------------------------
            # Other priorities are sorted in the order opposite
            # to the pipeline list.

            #------------------------------------------------------------------

            checkout_pipeline_group:
                group_id: 2
                priority_value: 2

            release_pipeline_group:
                group_id: 3
                priority_value: 3

            package_pipeline_group:
                group_id: 4
                priority_value: 4

            deploy_pipeline_group:
                group_id: 5
                priority_value: 5

            maven_pipeline_group:
                group_id: 6
                priority_value: 6

            update_pipeline_group:
                group_id: 7
                priority_value: 7

            init_pipeline_group:
                group_id: 8
                priority_value: 8

            poll_pipeline_group:
                group_id: 9
                priority_value: 9

            # Standalone group is lowest priority (among used ones)
            # to make sure such job are not run in between of pipelines.
            standalone_group:
                group_id: 10
                priority_value: 10

###############################################################################
# EOF
###############################################################################

