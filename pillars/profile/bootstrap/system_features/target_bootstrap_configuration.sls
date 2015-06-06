
###############################################################################
#

{% set project_name = salt['config.get']('this_system_keys:project_name') %}
{% set profile_name = salt['config.get']('this_system_keys:profile_name') %}
{% set master_minion_id = salt['config.get']('this_system_keys:master_minion_id') %}
{% set is_generic_profile = salt['config.get']('this_system_keys:is_generic_profile') %}
{% set default_username = salt['config.get']('this_system_keys:default_username') %}
{% set current_task_branch = salt['config.get']('this_system_keys:current_task_branch') %}

system_features:

    target_bootstrap_configuration:

        # The very initial sources (symlinks) to make Salt operational.
        # NOTE: These are only `states` and `pillars`. Even though there can
        #       be more than one repo for `states, only the common one
        #       is specified (which bootstraps the rest).
        bootstrap_sources:
            states: common-salt-states
            pillars: {{ project_name }}-salt-pillars

        # Repositories which actually get exported.
        export_sources:

            # Salt states.

            common-salt-states:
                export_enabled: True
                export_method: clone
                export_format: dir
                branch_name: '{{ current_task_branch }}'

            {% if project_name != 'common' %}
            {{ project_name }}-salt-states:
                export_enabled: True
                export_method: clone
                export_format: dir
                branch_name: '{{ current_task_branch }}'
            {% endif %}

            # Salt resources.

            common-salt-resources:
                export_enabled: True
                export_method: clone
                export_format: dir
                branch_name: '{{ current_task_branch }}'

            {% if project_name != 'common' %}
            {{ project_name }}-salt-resources:
                export_enabled: True
                export_method: clone
                export_format: dir
                branch_name: '{{ current_task_branch }}'
            {% endif %}

            # Salt pillars.

            {{ project_name }}-salt-pillars:
                # This repo is replaced by "target" pillar repository.
                export_enabled: False
                export_method: clone
                export_format: dir
            {% if is_generic_profile %}
                branch_name: '{{ current_task_branch }}'
            {% else %}
                branch_name: '{{ profile_name }}'
            {% endif %}

            # We only need to export pillars for target environment
            # but rename them.
            {{ project_name }}-salt-pillars-target:
                export_enabled: True
                export_method: clone
                export_format: dir
            {% if is_generic_profile %}
                branch_name: '{{ current_task_branch }}'
            {% else %}
                branch_name: '{{ profile_name }}'
            {% endif %}
                # This is required.
                # Pillars repository considered as "target" in the "source" environment
                # becomes "source" configuration in the "target" environment.
                target_repo_name: {{ project_name }}-salt-pillars

            # Other repositories.

            # ...

        target_minion_auto_accept: True

        target_master_minion_id: {{ master_minion_id }}

        target_default_username: {{ default_username }}

###############################################################################
# EOF
###############################################################################

