
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set project_name = props['project_name'] %}
{% set default_username = props['default_username'] %}

system_features:

    # `URI_prefix*` defines root or base relative which content
    # item location is looked up. For example, if `URI_prefix*` is
    # `http://some_file_server/depository/` than entries inside
    # `system_resources` are found under this URI.
    #
    # NOTE: There is no leading or trailing slashes in the value
    #       for `abs_resource_links_base_dir_path`.
    #
    # Value `abs_resource_target_base_dir_path` sepecifies physical location of
    # resource files on the filesystem.
    #
    # There will be a link created for all resources under
    # `{# abs_resource_links_base_dir_path #}` directory, for example:
    #   /srv/resources/{# rel_resource_link_base_dir_path #}/{# resource_link_basename #}
    # This is to access them using URI scheme, for example:
    #   salt://{# rel_resource_link_base_dir_path #}/{# resource_link_basename #}
    resource_repositories_configuration:

        URI_prefix_schemes_configurations:

            'salt://':
                abs_resource_links_base_dir_path: '/srv/resources'

            'http://':
                abs_resource_links_base_dir_path: TODO

        resource_respositories:

            common-resources:

                URI_prefix_scheme: 'salt://'

                rel_resource_link_path: 'resource_roots/common-resources'

                # TODO: Streamline it: use just `abs_resource_target_dir_path`
                #       without `resource_target_basename` because target is
                #       target - it is already abstracted by link name.
                # Both `abs_resource_base_path` and fully concatenated
                # `URI_prefix` specify base dir path relative to which value of
                # `item_parent_dir_path` key in registered content is specified.
                abs_resource_target_path: '/home/{{ default_username }}/Works/{{ props['parent_repo_name'] }}.git/salt/common-salt-resources.git'

            {% if project_name != 'common' %}
            {{ project_name }}-resources:

                URI_prefix_scheme: 'salt://'

                rel_resource_link_path: 'resource_roots/{{ project_name }}-resources'

                abs_resource_target_path: '/home/{{ default_username }}/Works/{{ props['parent_repo_name'] }}.git/salt/{{ project_name }}-salt-resources.git'
            {% endif %}

            # TODO: Add additional resource repositories below.


###############################################################################
# EOF
###############################################################################

