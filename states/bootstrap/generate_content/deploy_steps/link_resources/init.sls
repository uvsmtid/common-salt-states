#

###############################################################################
#

{% macro configure_selected_host_step_function(
        source_env_pillar
        ,
        target_env_pillar
        ,
        selected_host_name
        ,
        deploy_step
        ,
        deploy_step_config
        ,
        project_name
        ,
        profile_name
        ,
        requisite_config_file_id
        ,
        requisite_config_file_path
        ,
        target_contents_dir
        ,
        bootstrap_dir
    )
%}

{% set bootstrap_macro_lib = 'common/resource_symlinks/resources_macro_lib.sls' %}
{% from bootstrap_macro_lib import get_resource_symlink_for_bootstrap_target_profile with context %}

{% set os_platform = target_env_pillar['system_hosts'][selected_host_name]['os_platform'] %}
{% set resource_symlink = get_resource_symlink_for_bootstrap_target_profile(target_env_pillar) %}
{% set resource_base_dir_rel_path = 'resources/depository/' + project_name + '/' + profile_name %}

# Config for the step.
set_config_{{ requisite_config_file_id }}_{{ deploy_step }}:
    file.blockreplace:
        - name: '{{ requisite_config_file_path }}'
        - marker_start: '# Salt auto-config START: {{ requisite_config_file_id }}_{{ deploy_step }}'
        - marker_end:   '# Salt auto-config END:   {{ requisite_config_file_id }}_{{ deploy_step }}'
        - append_if_not_found: True
        - backup: False
        - content: |
            {{ deploy_step }} = {
                'step_enabled': {{ deploy_step_config['step_enabled'] }},
                'resource_symlink': '{{ resource_symlink }}',
                'resource_base_dir_rel_path': '{{ resource_base_dir_rel_path }}',
            }
        - show_changes: True
        - require:
            - file: req_file_{{ requisite_config_file_id }}

{% endmacro %}

###############################################################################
#

{% macro prepare_resources_step_function(
        source_env_pillar
        ,
        target_env_pillar
        ,
        deploy_step
        ,
        deploy_step_config
        ,
        project_name
        ,
        profile_name
        ,
        target_contents_dir
        ,
        bootstrap_dir
    )
%}

{% set resources_macro_lib = 'common/resource_symlinks/resources_macro_lib.sls' %}
{% from resources_macro_lib import get_registered_content_item_URI_from_pillar with context %}
{% from resources_macro_lib import get_registered_content_item_hash_from_pillar with context %}
{% from resources_macro_lib import get_registered_content_item_parent_dir_path_from_pillar with context %}
{% from resources_macro_lib import get_registered_content_item_base_name_from_pillar with context %}
{% from resources_macro_lib import get_registered_content_item_bootstrap_use_cases_from_pillar with context %}

# We simply point all repositories into single known location.
# This location is a symlink which is supposed to be created during `deploy`
# action to point to location of actual files.
# NOTE: Again, all resources are downloaded into the same directory regardless
#       of their URI prefix or original repository.
#       WARNING: This may result in potential conflicts of file paths in
#                different repositories. For now we assume that all
#                combinations of `item_parent_dir_path` + `item_base_name`
#                for all resource items are different.

{% set resource_respositories = target_env_pillar['system_features']['resource_repositories_configuration']['resource_respositories'] %}
{% set resource_base_dir_rel_path = 'resources/depository/' + project_name + '/' + profile_name %}

# Download resources for the project_name/profile_name.
# Resources are shared among all hosts in the same project_name/profile_name.
# TODO: Find a way to auto-limit resource download to only required items.
#       Currently, each content item simply has `bootstrap_use_cases` boolean
#       field to indicate whether it should be included or not.
# We use `URI_prefix` from current project_name/profile_name pillar assuming that
# it has access to all content items through the same prefix.
{% for content_item_id in target_env_pillar['system_resources'].keys() %} # content_item_id

# TODO: At the moment we only check boolean result of `bootstrap_use_cases` value.
#       Consider matching tailoring bootstrap package for specific use case
#       using `bootstrap_package_use_cases` list in bootstrap configuration.
{% if get_registered_content_item_bootstrap_use_cases_from_pillar(content_item_id, target_env_pillar) != 'False' %}

res_file_{{ content_item_id }}_{{ project_name }}_{{ profile_name }}:
    file.managed:
        # TODO: Resource location should be adjusted through symlinks just like symlinks to sources.
        #       At the moment all resources during `deploy` appear in
        #       `resources/{{ project_name }} ` directory.
        # NOTE: Resources are downloaded into `resources/depository/{{ project_name }}/..`, not
        #       under simply `resources/{{ project_name }}/..` to differentiate
        #       with other resources (not only those declared in `system_resources`.
        - name: '{{ target_contents_dir }}/{{ resource_base_dir_rel_path }}/{{ get_registered_content_item_parent_dir_path_from_pillar(content_item_id, target_env_pillar) }}/{{ get_registered_content_item_base_name_from_pillar(content_item_id, target_env_pillar) }}'
        - source: {{ get_registered_content_item_URI_from_pillar(content_item_id, target_env_pillar) }}
        - source_hash: {{ get_registered_content_item_hash_from_pillar(content_item_id, target_env_pillar) }}
        - makedirs: True
        - mode: 644
        {% set account_conf = source_env_pillar['system_accounts'][ source_env_pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
        - user: '{{ account_conf['username'] }}'
        - group: '{{ account_conf['primary_group'] }}'

{% endif %}

{% endfor %}

{% endmacro %}

###############################################################################
# EOF
###############################################################################

