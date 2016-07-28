# Set of macros to work with resources.

###############################################################################
#
{%- macro get_resource_symlink_for_bootstrap_target_env(
        target_env_pillar
    )
-%}

{%- set resource_symlink = target_env_pillar['posix_config_temp_dir'] + '/repositories/' + 'all' %}

{{- resource_symlink -}}

{%- endmacro -%}

###############################################################################
# item_base_name
###############################################################################

{%- macro get_registered_content_item_base_name_from_pillar(
        registered_content_item_id
        ,
        pillar_data
    )
-%}

{%- set registered_content_item_config = pillar_data['system_resources'][registered_content_item_id] -%}

{{- registered_content_item_config['item_base_name'] -}}

{%- endmacro -%}

#------------------------------------------------------------------------------

{%- macro get_registered_content_item_base_name(
        registered_content_item_id
    )
-%}

{{- get_registered_content_item_base_name_from_pillar(registered_content_item_id, pillar) -}}

{%- endmacro -%}

###############################################################################
# item_parent_dir_path | posix
###############################################################################

{%- macro get_registered_content_item_parent_dir_path_from_pillar(
        registered_content_item_id
        ,
        pillar_data
    )
-%}

{%- set registered_content_item_config = pillar_data['system_resources'][registered_content_item_id] -%}

{{- registered_content_item_config['item_parent_dir_path'] -}}

{%- endmacro -%}

#------------------------------------------------------------------------------

{%- macro get_registered_content_item_parent_dir_path(
        registered_content_item_id
    )
-%}

{{- get_registered_content_item_parent_dir_path_from_pillar(registered_content_item_id, pillar) -}}

{%- endmacro -%}

###############################################################################
# item_parent_dir_path | windows
###############################################################################

{%- macro get_registered_content_item_parent_dir_path_windows_from_pillar(
        registered_content_item_id
        ,
        pillar_data
    )
-%}

{%- set registered_content_item_config = pillar_data['system_resources'][registered_content_item_id] -%}

{{- registered_content_item_config['item_parent_dir_path']|replace("/", "\\") -}}

{%- endmacro -%}

#------------------------------------------------------------------------------

{%- macro get_registered_content_item_parent_dir_windows_path(
        registered_content_item_id
    )
-%}

{{- get_registered_content_item_parent_dir_path_windows_from_pillar(registered_content_item_id, pillar) -}}

{%- endmacro -%}

###############################################################################
# item_rel_path | posix
###############################################################################

{%- macro get_registered_content_item_rel_path_from_pillar(
        registered_content_item_id
        ,
        pillar_data
    )
-%}

{{- get_registered_content_item_parent_dir_path_from_pillar(registered_content_item_id, pillar_data) -}}
/
{{- get_registered_content_item_base_name_from_pillar(registered_content_item_id, pillar_data) -}}

{%- endmacro -%}

#------------------------------------------------------------------------------

{%- macro get_registered_content_item_rel_path(
        registered_content_item_id
    )
-%}

{{- get_registered_content_item_rel_path_from_pillar(registered_content_item_id, pillar) -}}

{%- endmacro -%}

###############################################################################
# item_rel_path | windows
###############################################################################

{%- macro get_registered_content_item_rel_path_windows_from_pillar(
        registered_content_item_id
        ,
        pillar_data
    )
-%}

{{- get_registered_content_item_parent_dir_path_windows_from_pillar(registered_content_item_id, pillar_data) -}}
\
{{- get_registered_content_item_base_name_from_pillar(registered_content_item_id, pillar_data) -}}

{%- endmacro -%}

#------------------------------------------------------------------------------

{%- macro get_registered_content_item_rel_path_windows(
        registered_content_item_id
    )
-%}

{{- get_registered_content_item_rel_path_windows_from_pillar(registered_content_item_id, pillar) -}}

{%- endmacro -%}

###############################################################################
# item_URI
###############################################################################

{%- macro get_registered_content_item_URI_from_pillar(
        registered_content_item_id
        ,
        pillar_data
    )
-%}

{%- set registered_content_item_config = pillar_data['system_resources'][registered_content_item_id] -%}
{%- set resource_repository_config = pillar_data['system_features']['resource_repositories_configuration']['resource_respositories'][registered_content_item_config['resource_repository']] -%}

{{- resource_repository_config['URI_prefix_scheme'] -}}
{{- resource_repository_config['rel_resource_link_path'] -}}
/
{{- get_registered_content_item_rel_path_from_pillar(registered_content_item_id, pillar_data) -}}

{%- endmacro -%}

#------------------------------------------------------------------------------

{%- macro get_registered_content_item_URI(
        registered_content_item_id
    )
-%}

{{- get_registered_content_item_URI_from_pillar(registered_content_item_id, pillar) -}}

{%- endmacro -%}


###############################################################################
# item_hash
###############################################################################

{%- macro get_registered_content_item_hash_from_pillar(
        registered_content_item_id
        ,
        pillar_data
    )
-%}

{%- set registered_content_item_config = pillar_data['system_resources'][registered_content_item_id] -%}

{#- If there is no `item_content_hash`, return None `~`. -#}
{%- if 'item_content_hash' in registered_content_item_config -%}
{{- registered_content_item_config['item_content_hash'] -}}
{%- else -%}
~
{%- endif -%}

{%- endmacro -%}

#------------------------------------------------------------------------------

{%- macro get_registered_content_item_hash(
        registered_content_item_id
    )
-%}

{{- get_registered_content_item_hash_from_pillar(registered_content_item_id, pillar) -}}

{%- endmacro -%}

###############################################################################
# URI_scheme_abs_links_base_dir_path
###############################################################################

{%- macro get_URI_scheme_abs_links_base_dir_path_from_pillar(
        URI_prefix_scheme
        ,
        pillar_data
    )
-%}

{%- set URI_prefix_scheme_configuration = pillar_data['system_features']['resource_repositories_configuration']['URI_prefix_schemes_configurations'][URI_prefix_scheme] -%}

{{- URI_prefix_scheme_configuration['abs_resource_links_base_dir_path'] -}}

{%- endmacro -%}

#------------------------------------------------------------------------------

{%- macro get_URI_scheme_abs_links_base_dir_path(
        URI_prefix_scheme
    )
-%}

{{- get_URI_scheme_abs_links_base_dir_path_from_pillar(URI_prefix_scheme, pillar) -}}

{%- endmacro -%}

###############################################################################
# resource_repository_target_path
###############################################################################

{%- macro get_resource_repository_target_path(
        resource_repository_id
    )
-%}

{%- set resource_repository_config = pillar['system_features']['resource_repositories_configuration']['resource_respositories'][resource_repository_id] -%}

{#-
At the moment, any `bootstrap_mode` requires rewrite of resource locations.
-#}
{%- if 'bootstrap_mode' in pillar -%}
{%- set resource_repository_target_path = get_resource_symlink_for_bootstrap_target_env(pillar) -%}
{%- else -%}
{%- set resource_repository_target_path = resource_repository_config['abs_resource_target_path'] -%}
{%- endif -%}

{{- resource_repository_target_path -}}

{%- endmacro -%}

###############################################################################
# resource_repository_link_path
###############################################################################


{%- macro get_resource_repository_link_path(
        resource_repository_id
    )
-%}

{%- set resource_repository_config = pillar['system_features']['resource_repositories_configuration']['resource_respositories'][resource_repository_id] -%}
{%- set resource_repository_config_URI_prefix_scheme = resource_repository_config['URI_prefix_scheme'] -%}
{%- set URI_prefix_scheme_configuration = pillar['system_features']['resource_repositories_configuration']['URI_prefix_schemes_configurations'][resource_repository_config_URI_prefix_scheme] -%}

{%- set URI_scheme_abs_links_base_dir_path = URI_prefix_scheme_configuration['abs_resource_links_base_dir_path'] -%}
{%- set rel_resource_link_path = resource_repository_config['rel_resource_link_path'] -%}

{{- URI_scheme_abs_links_base_dir_path -}}
/
{{- rel_resource_link_path -}}

{%- endmacro -%}

###############################################################################
# bootstrap_use_cases
###############################################################################

{%- macro get_registered_content_item_bootstrap_use_cases_from_pillar(
        registered_content_item_id
        ,
        pillar_data
    )
-%}

{%- set registered_content_item_config = pillar_data['system_resources'][registered_content_item_id] -%}

{%- if 'bootstrap_use_cases' in registered_content_item_config %}
{{- registered_content_item_config['bootstrap_use_cases'] -}}
{%- else -%}
True
{%- endif -%}

{%- endmacro -%}

#------------------------------------------------------------------------------

{%- macro get_registered_content_item_bootstrap_use_cases(
        registered_content_item_id
    )
-%}

{{- get_registered_content_item_bootstrap_use_cases_from_pillar(registered_content_item_id, pillar) -}}

{%- endmacro -%}

###############################################################################
# EOF
###############################################################################

