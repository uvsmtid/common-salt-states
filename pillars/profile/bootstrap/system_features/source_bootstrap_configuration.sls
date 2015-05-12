
###############################################################################
#

{% set master_minion_id = salt['config.get']('this_system_keys:master_minion_id') %}
{% set profile = salt['config.get']('this_system_keys:profile') %}

system_features:

    source_bootstrap_configuration:

        enable_bootstrap_target_envs:
            {{ profile }}:

        bootstrap_package_use_cases:
            - 'initial-online-node'
            - 'offline-minion-installer'

        generate_packages: False

###############################################################################
# EOF
###############################################################################

