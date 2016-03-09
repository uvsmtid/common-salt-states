
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set master_minion_id = props['master_minion_id'] %}

system_features:

    wildfly_deployments:

        standard_wildfly:
            resource_id: wildfly_application_server_distribution_zip
            archive_format: zip
            root_subdir: 'wildfly-10.0.0.Final'
            owner_user: master_minion_user
            destination_dir_path: Apps/wildfly/standard_wildfly

    wildfly_instances:

        node-1:
            target_system_role: wildfly_node_1_role
            deployment_id: standard_wildfly

            file_templates:
                example:
                    source_url: 'salt://common/wildfly/templates/standalone.xml'
                    template_type: jinja
                    destination_path: 'configuration/standalone.xml'
                    config_data:
                        key1: value1
                        key2: value2

        node-2:
            target_system_role: wildfly_node_2_role
            deployment_id: standard_wildfly

            file_templates:
                example:
                    source_url: 'salt://common/wildfly/templates/standalone.xml'
                    template_type: jinja
                    destination_path: 'configuration/standalone.xml'
                    config_data:
                        key1: value1
                        key2: value2

###############################################################################
# EOF
###############################################################################

