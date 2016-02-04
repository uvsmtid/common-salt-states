
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

system_features:

    configure_sonar_qube:

        # TODO: Add list of plugins to install.
        # Each plugin is a resource_id.
        install_plugins:
            - sonar_plugin_java

###############################################################################
# EOF
###############################################################################

