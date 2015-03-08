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

{% set bootstrap_platform = target_env_pillar['system_hosts'][selected_host_name]['bootstrap_platform'] %}

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
                #       location expected location.
            }
        - show_changes: True
        - require:
            - file: {{ requisite_config_file_id }}

# Download resources for the project/profile.
# Resources are shared among all hosts in the same project/profile.
# TODO: Find a way to limit resource download to only required items.
#       Should content items be tagged if they are used (to be downloaded)?
#       Should `bootstrap_configuration` specify what set of content itmes
#       should be downloaded via list of items or list of tags?
# We use `URI_prefix` from current project/profile pillar assuming that
# it has access to all content items through the same prefix.
{% set URI_prefix = target_env_pillar['registered_content_config']['URI_prefix'] %}
{% for content_item_id in target_env_pillar['registered_content_items'].keys() %} # content_item_id
{% set content_item_conf = target_env_pillar['registered_content_items'][content_item_id] %}

{{ content_item_id }}_{{ project_name }}_{{ profile_name }}_{{ selected_host_name }}:
    file.managed:
        # TODO: Resource location should be adjusted through symlinks just like symlinks to sources.
        #       At the moment all resources during `deploy` appear in
        #       `resources/{{ project_name }} ` directory.
        # NOTE: Resources are downloaded into `resources/depository/{{ project_name }}`, not
        #       under simply `resources/{{ project_name }}` to differentiate
        #       with other resources (not only those declared in `registered_content_items`.
        - name: '{{ bootstrap_dir }}/resources/depository/{{ project_name }}/{{ content_item_conf['item_parent_dir_path'] }}/{{ content_item_conf['item_base_name'] }}'
        - source: '{{ URI_prefix }}/{{ content_item_conf['item_parent_dir_path'] }}/{{ content_item_conf['item_base_name'] }}'
        - source_hash: {{ content_item_conf['item_content_hash'] }}
        - makedirs: True
        - mode: 644
        - user: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ source_env_pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}'

{% endfor %}

{% endmacro %}

