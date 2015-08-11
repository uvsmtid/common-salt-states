
###############################################################################
#

# Import `maven_repo_names`.
{% set maven_repo_names_path = profile_root.replace('.', '/') + '/common/system_features/maven_repo_names.yaml' %}
{% import_yaml maven_repo_names_path as maven_repo_names %}

{% set maven_job_name_prefix = 'maven.top.pom.build' %}

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
        #       trigger_jobs:
        #           # docs/pillars/common/system_features/configure_jenkins/job_configs/_id/trigger_jobs/readme.md
        #

            ###################################################################
            # Set of trigger-jobs which are not supposed to be doing much.
            # They are only used to trigger downstram jobs.

            # NOTE: At the moment this job simply refers to another
            #       `update_salt_master_sources` job without actually
            #       executing it (see `skip_script_execution`).
            {% set job_id = 'trigger_on_demand' %}
            {{ job_id }}:
                enabled: True

                restrict_to_system_role:
                    - controller_role

                trigger_jobs:
                    - update_salt_master_sources

                skip_script_execution: True

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/update_salt_master_sources.xml'

            # NOTE: At the moment this job simply tries to do what
            #       `update_salt_master_sources` does but it skips
            #       any updates (see `skip_script_execution`) and does it
            #       on a timely basis.
            {% set job_id = 'trigger_on_timer' %}
            {{ job_id }}:
                enabled: True

                restrict_to_system_role:
                    - controller_role

                timer_spec: 'H */2 * * *'

                trigger_jobs:
                    - update_salt_master_sources

                skip_script_execution: True

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/update_salt_master_sources.xml'

            # TODO: At the moment this job simply tries to do what
            #       `update_salt_master_sources` does but it does trigger
            #       pipeline even if there is no changes.
            {% set job_id = 'trigger_on_changes' %}
            {{ job_id }}:
                enabled: True

                restrict_to_system_role:
                    - controller_role

                trigger_jobs:
                    - update_salt_master_sources

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/update_salt_master_sources.xml'

            ###################################################################
            # The `infra` pipeline

            {% set job_id = 'update_salt_master_sources' %}
            {{ job_id }}:
                enabled: True

                restrict_to_system_role:
                    - controller_role

                trigger_jobs:
                    - restart_master_salt_services

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            {% set job_id = 'restart_master_salt_services' %}
            {{ job_id }}:
                enabled: True

                restrict_to_system_role:
                    - controller_role

                timer_spec: ~

                trigger_jobs:
                    - configure_jenkins_jobs

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            {% set job_id = 'configure_jenkins_jobs' %}
            {{ job_id }}:
                enabled: True

                restrict_to_system_role:
                    - controller_role

                timer_spec: ~

                trigger_jobs:
                    - build_bootstrap_package

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            {% set job_id = 'build_bootstrap_package' %}
            {{ job_id }}:
                enabled: True

                restrict_to_system_role:
                    - controller_role

                timer_spec: ~

                trigger_jobs:
                    - configure_vagrant

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            {% set job_id = 'configure_vagrant' %}
            {{ job_id }}:
                enabled: True

                restrict_to_system_role:
                    - controller_role

                timer_spec: ~

                trigger_jobs:
                    - destroy_vagrant_hosts

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            {% set job_id = 'destroy_vagrant_hosts' %}
            {{ job_id }}:
                enabled: True

                restrict_to_system_role:
                    - controller_role

                timer_spec: ~

                trigger_jobs:
                    - remove_salt_minion_keys

                skip_script_execution: False

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            {% set job_id = 'remove_salt_minion_keys' %}
            {{ job_id }}:
                enabled: True

                restrict_to_system_role:
                    - controller_role

                timer_spec: ~

                trigger_jobs:
                    - instantiate_vagrant_hosts

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            {% set job_id = 'instantiate_vagrant_hosts' %}
            {{ job_id }}:
                enabled: True

                restrict_to_system_role:
                    - controller_role

                timer_spec: ~

                trigger_jobs:
                    - run_salt_orchestrate

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            {% set job_id = 'run_salt_orchestrate' %}
            {{ job_id }}:
                enabled: True

                restrict_to_system_role:
                    - controller_role

                timer_spec: ~

                trigger_jobs:
                    - run_salt_highstate

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            {% set job_id = 'run_salt_highstate' %}
            {{ job_id }}:
                enabled: True

                restrict_to_system_role:
                    - controller_role

                # NOTE: This tests that this field is optional
                #       (can be omitted).
                #{#
                timer_spec: ~
                #}#

                trigger_jobs:
                    - maven_build_all

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            {% set job_id = 'maven_build_all' %}
            {{ job_id }}:
                enabled: True

                restrict_to_system_role:
                    - controller_role

                trigger_jobs:
                    {% for maven_repo_name in maven_repo_names %}
                    - {{ maven_job_name_prefix }}.{{ maven_repo_name }}
                    {% endfor %}

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            ###################################################################
            # Build jobs per repo

            {% for maven_repo_name in maven_repo_names %}

            {{ maven_job_name_prefix }}.{{ maven_repo_name }}:
                enabled: True

                restrict_to_system_role:
                    - jenkins_slave_role

                trigger_jobs: ~

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/maven_project_job.xml'
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

            ###################################################################
            # Build release

            {% set job_id = 'init_dynamic_build_descriptor' %}
            {{ job_id }}:
                enabled: True

                restrict_to_system_role:
                    - controller_role

                trigger_jobs:
                    - restart_master_salt_services

                job_config_function_source: 'common/jenkins/configure_jobs_ext/simple_xml_template_job.sls'
                job_config_data:
                    xml_config_template: 'common/jenkins/configure_jobs_ext/{{ job_id }}.xml'

            ###################################################################
            # TODO: Add additional jobs for release pipeline?
            # - Merge build branches?
            # - Save dynamic build descriptor?
            # - Upload artifacts somewhere?
            # - Create tags and push them to upstream?

        #######################################################################
        #

        view_configs:

            infra:
                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/list_view.xml'

                    job_list:
                        - update_salt_master_sources
                        - restart_master_salt_services
                        - configure_jenkins_jobs
                        - build_bootstrap_package
                        - configure_vagrant
                        - destroy_vagrant_hosts
                        - remove_salt_minion_keys
                        - instantiate_vagrant_hosts
                        - run_salt_orchestrate
                        - run_salt_highstate

            maven:
                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/list_view.xml'

                    job_list:
                        - maven_build_all
                        {% for maven_repo_name in maven_repo_names %}
                        - {{ maven_job_name_prefix }}.{{ maven_repo_name }}
                        {% endfor %}

            infra-pipeline:
                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/build_pipeline_view.xml'

                    first_job_name: update_salt_master_sources

            maven-pipeline:
                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/build_pipeline_view.xml'

                    first_job_name: maven_build_all

            release-pipeline:
                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/build_pipeline_view.xml'

                    first_job_name: init_dynamic_build_descriptor

            triggers:
                enabled: True

                view_config_function_source: 'common/jenkins/configure_views_ext/simple_xml_template_view.sls'
                view_config_data:
                    xml_config_template: 'common/jenkins/configure_views_ext/list_view.xml'

                    job_list:
                        - trigger_on_demand
                        - trigger_on_timer
                        - trigger_on_changes
                        - init_dynamic_build_descriptor

###############################################################################
# EOF
###############################################################################

