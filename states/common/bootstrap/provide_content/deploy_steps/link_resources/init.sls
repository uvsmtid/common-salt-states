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
                # TODO: Nothing to do at the momement.
                #       All resources are simply downloaded in their
                #       expected location.
            }
        - show_changes: True
        - require:
            - file: {{ requisite_config_file_id }}

{% set resources_macro_lib = 'common/resource_symlinks/resources_macro_lib.sls' %}
{% from resources_macro_lib import get_registered_content_item_URI_from_pillar with context %}
{% from resources_macro_lib import get_registered_content_item_hash_from_pillar with context %}
{% from resources_macro_lib import get_registered_content_item_parent_dir_path_from_pillar with context %}

# Rewrite `target_env_pillar`.
# See:
#   http://stackoverflow.com/q/11047886/441652
#   http://stackoverflow.com/a/3479970/441652
# For each of the `resource_respositories`, `URI_prefix_scheme` should
# be changed to `salt://`.

{% set base_dir = bootstrap_dir + '/resources/rewritten_pillars/' + project_name + '/' + profile_name %}
{% set URI_prefix_schemes_configurations = target_env_pillar['system_features']['resource_repositories_configuration']['URI_prefix_schemes_configurations'] %}

# Change target pillar.
{% for URI_prefix_schemes_configuration_id in URI_prefix_schemes_configurations.keys() %} # URI_prefix_schemes_configuration_id
{% set URI_prefix_schemes_configuration = URI_prefix_schemes_configurations[URI_prefix_schemes_configuration_id] %}

# Save current value into swap location.
{% do URI_prefix_schemes_configuration.update( { 'bootstrap_swap_value': URI_prefix_schemes_configuration['abs_resource_links_base_dir_path'] } ) %}
{% do URI_prefix_schemes_configuration.update( { 'abs_resource_links_base_dir_path': base_dir } ) %}

{% endfor %} # URI_prefix_schemes_configuration_id

{{ requisite_config_file_id }}_{{ deploy_step }}_extract_sources_{{ project_name }}_{{ profile_name }}_rewirte_pillar:
    file.managed:
        # Note that location of the pillar is _assumed_.
        # TODO: Make location of the pillar declared, otherwise if pillar is
        #       located in different place, rewrite will be merge with
        #       unpredictable results.
        - name: '{{ base_dir }}/pillars/{{ project_name }}/{{ profile_name }}.sls'
        - source: ~
        - makedirs: True
        # Render `target_env_pillar` as JSON.
        - contents: |
            {{ target_env_pillar }}

# Change target pillar back.
{% for URI_prefix_schemes_configuration_id in URI_prefix_schemes_configurations.keys() %} # URI_prefix_schemes_configuration_id
{% set URI_prefix_schemes_configuration = URI_prefix_schemes_configurations[URI_prefix_schemes_configuration_id] %}

# Save current value into swap location.
{% do URI_prefix_schemes_configuration.update( { 'abs_resource_links_base_dir_path': URI_prefix_schemes_configuration['bootstrap_swap_value'] } ) %}
{% do URI_prefix_schemes_configuration.update( { 'bootstrap_swap_value': None } ) %}

{% endfor %} # URI_prefix_schemes_configuration_id


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
        # NOTE: Resources are downloaded into `resources/depository/{{ project_name }}`, not
        #       under simply `resources/{{ project_name }}` to differentiate
        #       with other resources (not only those declared in `registered_content_items`.
        - name: '{{ bootstrap_dir }}/resources/depository/{{ project_name }}/{{ get_registered_content_item_parent_dir_path_from_pillar(content_item_id, target_env_pillar) }}'
        - source: '{{ get_registered_content_item_URI_from_pillar(content_item_id, target_env_pillar) }}'
        - source_hash: '{{ get_registered_content_item_hash_from_pillar(content_item_id, target_env_pillar) }}'
        - makedirs: True
        - mode: 644
        - user: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}'

{% endfor %}

{% endmacro %}

