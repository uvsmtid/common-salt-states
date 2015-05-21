
###############################################################################
#

{% set master_minion_id = salt['config.get']('this_system_keys:master_minion_id') %}
{% set profile_name = salt['config.get']('this_system_keys:profile_name') %}

system_features:

    target_bootstrap_configuration:

        # The very initial sources (symlinks) to make Salt operational.
        # NOTE: These are only `states` and `pillars`. Even though there can
        #       be more than one repo for `states, only the common one
        #       is specified (which bootstraps the rest).
        bootstrap_sources:
            states: common-salt-states
            # Normally, pillars are supposed to be in a separate repository.
            pillars: common-salt-states

        # Repositories which actually get exported.
        export_sources:
            common-salt-states:
                export_enabled: True
                export_method: clone
                export_format: dir
                branch_name: jenkins-slave-role
            common-salt-resources:
                export_enabled: True
                export_method: clone
                export_format: dir
                branch_name: master

        target_minion_auto_accept: True

        target_master_minion_id: {{ master_minion_id }}

###############################################################################
# EOF
###############################################################################
