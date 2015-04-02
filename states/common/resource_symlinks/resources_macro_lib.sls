# Set of macros to work with resources.

###############################################################################
# item_base_name
###############################################################################

{%- macro get_registered_content_item_base_name_from_pillar(
        registered_content_item_id
        ,
        pillar_data
    )
-%}

{%- set registered_content_item_config = pillar_data['registered_content_items'][registered_content_item_id] -%}

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
# item_parent_dir_path
###############################################################################

{%- macro get_registered_content_item_parent_dir_path_from_pillar(
        registered_content_item_id
        ,
        pillar_data
    )
-%}

{%- set registered_content_item_config = pillar_data['registered_content_items'][registered_content_item_id] -%}

{{- registered_content_item_config['item_parent_dir_path'] -}}

{%- endmacro -%}

#------------------------------------------------------------------------------

{%- macro get_registered_content_item_parent_dir_path(
        registered_content_item_id
    )
-%}

{{- get_registered_content_item_parent_dir_path(registered_content_item_id, pillar) -}}

{%- endmacro -%}

###############################################################################
# item_rel_path
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

{{- get_registered_content_item_rel_path(registered_content_item_id, pillar) -}}

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

{%- set registered_content_item_config = pillar_data['registered_content_items'][registered_content_item_id] -%}
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

{%- set registered_content_item_config = pillar_data['registered_content_items'][registered_content_item_id] -%}

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
{%- set resource_repository_target_path = resource_repository_config['abs_resource_target_path'] -%}

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
# EOF
###############################################################################

