#

{% macro configure_deploy_step_function(
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
        bootstrap_dir
    )
%}

{% set os_platform = target_env_pillar['system_hosts'][selected_host_name]['os_platform'] %}
{% set resource_symlink = target_env_pillar['posix_config_temp_dir'] + '/all_repositories/' + project_name + '/' + profile_name %}
{% set resource_base_dir_rel_path = 'resources/depository/' + project_name + '/' + profile_name %}

# Config for the step.
{{ requisite_config_file_id }}_{{ deploy_step }}:
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
            - file: {{ requisite_config_file_id }}

{% set resources_macro_lib = 'common/resource_symlinks/resources_macro_lib.sls' %}
{% from resources_macro_lib import get_registered_content_item_URI_from_pillar with context %}
{% from resources_macro_lib import get_registered_content_item_hash_from_pillar with context %}
{% from resources_macro_lib import get_registered_content_item_parent_dir_path_from_pillar with context %}
{% from resources_macro_lib import get_registered_content_item_base_name_from_pillar with context %}

# Rewrite `target_env_pillar`.
# See:
#   http://stackoverflow.com/q/11047886/441652
#   http://stackoverflow.com/a/3479970/441652
# We simply point all repositories into single known location.
# This location is a symlink which is supposed to be created during `deploy`
# action to point to location of actual files.
# NOTE: Again, all resources are downloaded into the same directory regardless
#       of their URI prefix or original repository.
#       WARNING: This may result in potential conflicts of file paths in
#                different repositories. For now we assume that all
#                combinations of `item_parent_dir_path` + `item_base_name`
#                for all resource items are different.
# TODO: Make it more flexible. Some resources shouldn't be downloaded, others
#       should be separated per repository type, etc.

{% set base_dir = bootstrap_dir + '/resources/rewritten_pillars/' + project_name + '/' + profile_name %}
{% set resource_respositories = target_env_pillar['system_features']['resource_repositories_configuration']['resource_respositories'] %}

# Change target pillar.
{% for resource_respository_id in resource_respositories.keys() %} # resource_respository_id
{% set resource_respository_config = resource_respositories[resource_respository_id] %}

# Save current value into swap location.
{% do resource_respository_config.update( { 'bootstrap_swap_value': resource_respository_config['abs_resource_target_path'] } ) %}
# Write new value.
{% do resource_respository_config.update( { 'abs_resource_target_path': resource_symlink } ) %}

{% endfor %} # resource_respository_id

# Generate "ugly" version of rewritten profile pillar data.
{{ requisite_config_file_id }}_{{ deploy_step }}_extract_sources_{{ project_name }}_{{ profile_name }}_rewirte_pillar:
    file.managed:
        # Note that location of the pillar is _assumed_.
        # TODO: Make location of the pillar declared, otherwise if pillar is
        #       located in different place, rewrite will be merge with
        #       unpredictable results.
        - name: '{{ base_dir }}/pillars/{{ project_name }}/profile/{{ profile_name }}.sls.ugly'
        - source: ~
        - makedirs: True
        - user: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}'
        # Render `target_env_pillar` as JSON.
        - contents: |
            {{ target_env_pillar }}

# Convert generated YAML file in pretty format.
{{ requisite_config_file_id }}_{{ deploy_step }}_extract_sources_{{ project_name }}_{{ profile_name }}_convert_rewritten_pillar_pretty:
    cmd.run:
        - name: '{{ bootstrap_dir }}/pretty_yaml2json.py {{ base_dir }}/pillars/{{ project_name }}/profile/{{ profile_name }}.sls.ugly > {{ base_dir }}/pillars/{{ project_name }}/profile/{{ profile_name }}.sls'
        - user: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}'
        - require:
            - file: {{ requisite_config_file_id }}_{{ deploy_step }}_extract_sources_{{ project_name }}_{{ profile_name }}_rewirte_pillar

# Change target pillar back.
{% for resource_respository_id in resource_respositories.keys() %} # resource_respository_id
{% set resource_respository_config = resource_respositories[resource_respository_id] %}

# Save current value into swap location.
{% do resource_respository_config.update( { 'abs_resource_target_path': resource_respository_config['bootstrap_swap_value'] } ) %}
{% do resource_respository_config.update( { 'bootstrap_swap_value': None } ) %}

{% endfor %} # resource_respository_id

# Download resources for the project/profile.
# Resources are shared among all hosts in the same project/profile.
# TODO: Find a way to limit resource download to only required items.
#       Should content items be tagged if they are used (to be downloaded)?
#       Should `bootstrap_configuration` specify what set of content itmes
#       should be downloaded via list of items or list of tags?
# We use `URI_prefix` from current project/profile pillar assuming that
# it has access to all content items through the same prefix.
{% for content_item_id in target_env_pillar['registered_content_items'].keys() %} # content_item_id

{{ content_item_id }}_{{ project_name }}_{{ profile_name }}_{{ selected_host_name }}:
    file.managed:
        # TODO: Resource location should be adjusted through symlinks just like symlinks to sources.
        #       At the moment all resources during `deploy` appear in
        #       `resources/{{ project_name }} ` directory.
        # NOTE: Resources are downloaded into `resources/depository/{{ project_name }}/..`, not
        #       under simply `resources/{{ project_name }}/..` to differentiate
        #       with other resources (not only those declared in `registered_content_items`.
        - name: '{{ bootstrap_dir }}/{{ resource_base_dir_rel_path }}/{{ get_registered_content_item_parent_dir_path_from_pillar(content_item_id, target_env_pillar) }}/{{ get_registered_content_item_base_name_from_pillar(content_item_id, target_env_pillar) }}'
        - source: {{ get_registered_content_item_URI_from_pillar(content_item_id, target_env_pillar) }}
        - source_hash: {{ get_registered_content_item_hash_from_pillar(content_item_id, target_env_pillar) }}
        - makedirs: True
        - mode: 644
        - user: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}'

{% endfor %}

{% endmacro %}

