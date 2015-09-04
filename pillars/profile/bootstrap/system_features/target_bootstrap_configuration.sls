
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
{% set maven_repo_names_path = profile_root.replace('.', '/') + '/common/system_maven_artifacts/maven_repo_names.yaml' %}
{% import_yaml maven_repo_names_path as maven_repo_names %}
# TODO: Use `maven_repo_names` subkey in `maven_repo_names.yaml`.

# Import dynamic build descriptor to influence name of repo branches
# which has to be exported during the build.
{% set dynamic_build_descriptor_path = profile_root.replace('.', '/') + '/dynamic_build_descriptor.yaml' %}
{% import_yaml dynamic_build_descriptor_path as dynamic_build_descriptor %}

# This is in-plave macro for common logic to set repo branch name.
# The indentation has to be preserved for proper YAML rendering.
{% macro set_repo_branch_name(repo_name, default_branch) %}
                # NOTE: Quick fix for pillars which deal with released
                #       dyn build desc (when normal branches should be used
                #       and not ugly long build branches).
                #       We only need to use build branches
                #       during build pipeline.
                {% if 'released' in dynamic_build_descriptor and dynamic_build_descriptor['released'] %}
                branch_name: '{{ default_branch }}'
                {% else %}

                {% if 'build_branches' in dynamic_build_descriptor %}
                {% set branch_name = dynamic_build_descriptor['build_branches'][repo_name] %}
                branch_name: '{{ branch_name }}'
                {% else %}
                branch_name: '{{ default_branch }}'
                {% endif %}

                {% endif %}
{% endmacro %}

system_features:

    target_bootstrap_configuration:

        # The very initial sources (symlinks) to make Salt operational.
        # NOTE: These are only `states` and `pillars`. Even though there can
        #       be more than one repo for `states, only the common one
        #       is specified (which bootstraps the rest).
        bootstrap_sources:
            states: common-salt-states
            {% if is_generic_profile %}
            pillars: {{ project_name }}-salt-states
            {% else %}
            pillars: {{ project_name }}-salt-pillars
            {% endif %}

        # Repositories which actually get exported.
        export_sources:

            # All non-pillar repositories (not related to configuration)
            # are expected to have branch named after current
            # development task by convention.
            # This default keeps configuration simple and stable.
            #
            # On the other hand, pillar repositories (profiles) are
            # specific to target environment and can have any names.

            # Main repository with submodules.

            {% if props['parent_repo_name'] %}
            {% set repo_name = props['parent_repo_name'] %}
            {{ repo_name }}:
                # NOTE: We don't need to export root repository.
                export_enabled: False
                export_method: clone
                export_format: dir
                {{ set_repo_branch_name(repo_name, current_task_branch) }}
            {% endif %}

            # Salt states.

            {% set repo_name = 'common-salt-states' %}
            {{ repo_name }}:
                export_enabled: True
                export_method: clone
                export_format: dir
                {{ set_repo_branch_name(repo_name, current_task_branch) }}

            {% if project_name != 'common' %}
            {% set repo_name = project_name + '-salt-states' %}
            {{ repo_name }}:
                export_enabled: True
                export_method: clone
                export_format: dir
                {{ set_repo_branch_name(repo_name, current_task_branch) }}
            {% endif %}

            # Salt resources.

            {% set repo_name = 'common-salt-resources' %}
            {{ repo_name }}:
                # NOTE: Disable export because resource items
                #       are downloaded one by one.
                export_enabled: False
                # NOTE: When export enabled, in order to
                #       cut size of resources repository,
                #       get only checked out data (without history)
                #       using `checkout-index` method.
                export_method: checkout-index
                export_format: dir
                {{ set_repo_branch_name(repo_name, current_task_branch) }}

            {% if project_name != 'common' %}
            {% set repo_name = project_name + '-salt-resources' %}
            {{ repo_name }}:
                # NOTE: Disable export because resource items
                #       are downloaded one by one.
                export_enabled: False
                # NOTE: When export enabled, in order to
                #       cut size of resources repository,
                #       get only checked out data (without history)
                #       using `checkout-index` method.
                export_method: checkout-index
                export_format: dir
                {{ set_repo_branch_name(repo_name, current_task_branch) }}
            {% endif %}

            # Salt pillars.

            {% set repo_name = project_name + '-salt-pillars' %}
            {{ repo_name }}:
                # This repo is replaced by "target" pillar repository.
                export_enabled: False
                export_method: clone
                export_format: dir
                # If it was actually exportable, the default for
                # target pillar repository would be profile name.
                {{ set_repo_branch_name(repo_name, profile_name) }}

            # We only need to export pillars for target environment
            # but rename them.
            {% set repo_name = project_name + '-salt-pillars.bootstrap-target' %}
            {{ repo_name }}:
                export_enabled: True
                export_method: clone
                export_format: dir
                # NOTE: Choice of the target pillar is special.
                # During the build, target pillar is selected and
                # the repository is adjusted to point to the branch
                # with corresponding profile. The following logic
                # makes sure that the target pillar is influenced
                # by the selection.
                # NOTE: Quick fix for pillars which deal with released
                #       dyn build desc (when normal branches should be used
                #       and not ugly long build branches).
                #       We only need to use build branches
                #       during build pipeline.
                {% if 'released' in dynamic_build_descriptor and dynamic_build_descriptor['released'] %}
                branch_name: '{{ profile_name }}'
                {% else %}

                {% if 'environ' in dynamic_build_descriptor and 'TARGET_PROFILE_NAME' in dynamic_build_descriptor['environ'] %}
                {% set branch_name = dynamic_build_descriptor['environ']['TARGET_PROFILE_NAME'] %}
                branch_name: '{{ branch_name }}'
                {% else %}
                branch_name: '{{ profile_name }}'
                {% endif %}

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

