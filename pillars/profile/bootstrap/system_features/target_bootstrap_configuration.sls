
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set project_name = props['project_name'] %}
{% set profile_name = props['profile_name'] %}
{% set master_minion_id = props['master_minion_id'] %}
{% set is_generic_profile = props['is_generic_profile'] %}
{% set default_username = props['default_username'] %}
{% set current_task_branch = props['current_task_branch'] %}

# Import `maven_repo_names`.
{% set maven_repo_names_path = profile_root.replace('.', '/') + '/common/system_features/maven_repo_names.yaml' %}
{% import_yaml maven_repo_names_path as maven_repo_names %}

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
                # NOTE: Disable export because resource items
                #       are downloaded one by one.
                export_enabled: False
                # NOTE: When export enabled, in order to
                #       cut size of resources repository,
                #       get only checked out data (without history)
                #       using `checkout-index` method.
                export_method: checkout-index
                export_format: dir
                branch_name: '{{ current_task_branch }}'

            {% if project_name != 'common' %}
            {{ project_name }}-salt-resources:
                # NOTE: Disable export because resource items
                #       are downloaded one by one.
                export_enabled: False
                # NOTE: When export enabled, in order to
                #       cut size of resources repository,
                #       get only checked out data (without history)
                #       using `checkout-index` method.
                export_method: checkout-index
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
            {{ project_name }}-salt-pillars.bootstrap-target:
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

            # Maven component repositories.

            {% for maven_repo_name in maven_repo_names %}

            {{ maven_repo_name }}:
                export_enabled: False
                export_method: git-archive
                export_format: tar
                branch_name: ~

            {% endfor %}

            # Other repositories.

            # ...

        target_minion_auto_accept: True

        target_master_minion_id: {{ master_minion_id }}

        target_default_username: {{ default_username }}

###############################################################################
# EOF
###############################################################################

