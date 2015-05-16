###############################################################################
#

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
                abs_resource_target_path: '/tmp/common-salt-resources.git'

###############################################################################
# EOF
###############################################################################

