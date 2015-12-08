
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set bootstrap_target_envs = props['load_bootstrap_target_envs'].keys() %}
{% set bootstrap_target_envs = bootstrap_target_envs + [ props['profile_name'] ] %}

system_features:

    source_bootstrap_configuration:

        # NOTE: By default all bootstrap target environments are enabled.
        #       However, there is only one bootstrap target pillars repository.
        #       Therefore, the same bootstrap package is generated as many
        #       times as there are enabled environments.
        #       In order to optimize, bootstrap generation should be run
        #       with option to override this pillar:
        #         salt-call state.sls bootstrap.generate_content \
        #           pillar="{ system_features: { source_bootstrap_configuration: { enable_bootstrap_target_envs: [ REQUIRED_TARGET ] } } }"
        enable_bootstrap_target_envs: {{ bootstrap_target_envs|json }}

        bootstrap_package_use_cases:
            - 'initial-online-node'
            - 'offline-minion-installer'

        generate_packages: True

###############################################################################
# EOF
###############################################################################

