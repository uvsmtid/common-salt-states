
###############################################################################
#

{% set master_minion_id = salt['config.get']('this_system_keys:master_minion_id') %}
{% set profile = salt['config.get']('this_system_keys:profile') %}

system_features:

    target_bootstrap_configuration:

        # The very initial sources (symlinks) to make Salt operational.
        # NOTE: These are only `states` and `pillars`. Even though there can
        #       be more than one repo for `states, only the common one
        #       is specified (which bootstraps the rest).
        bootstrap_sources:
            states: common-salt-states
            pillars: common-salt-pillars

        # Repositories which actually get exported.
        export_sources:

            # Salt states.

            common-salt-states:
                export_enabled: True
                export_method: clone
                export_format: dir
                branch_name: develop

            # Salt resources.

            common-salt-resources:
                export_enabled: True
                export_method: clone
                export_format: dir
                branch_name: develop

            # Salt pillars.

            common-salt-pillars:
                # This repo is replaced by "target" pillar repository.
                export_enabled: False
                export_method: clone
                export_format: dir
                branch_name: develop

            # We only need to export pillars for target environment
            # but rename them.
            common-salt-pillars.target:
                export_enabled: True
                export_method: clone
                export_format: dir
                branch_name: develop
                # This is required.
                # Pillars repository considered as "target" in the "source" environment
                # becomes "source" configuration in the "target" environment.
                target_repo_name: common-salt-pillars

            # Other repositories.

            # ...

        target_minion_auto_accept: True

        target_master_minion_id: {{ master_minion_id }}

###############################################################################
# EOF
###############################################################################

