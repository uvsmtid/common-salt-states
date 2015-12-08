
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set profile_name = props['profile_name'] %}

system_features:

    source_bootstrap_configuration:

        enable_bootstrap_target_envs:
            {{ profile_name }}: ~

        bootstrap_package_use_cases:
            - 'initial-online-node'
            - 'offline-minion-installer'

        generate_packages: True

###############################################################################
# EOF
###############################################################################

