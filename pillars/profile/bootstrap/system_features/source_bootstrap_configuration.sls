
###############################################################################
#

{% set profile_name = salt['config.get']('this_system_keys:profile_name') %}

system_features:

    source_bootstrap_configuration:

        enable_bootstrap_target_envs:
            {{ profile_name }}:

        bootstrap_package_use_cases:
            - 'initial-online-node'
            - 'offline-minion-installer'

        generate_packages: False

###############################################################################
# EOF
###############################################################################

