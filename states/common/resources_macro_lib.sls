# Set of macros to work with resources.

###############################################################################

{%- macro get_registered_content_item_URI(
        registered_content_item_id
    )
-%}

{%- set registered_content_item_config = pillar['registered_content_items'][registered_content_item_id] -%}
{%- set resource_repository_config = pillar['system_features']['resource_repositories_configuration']['resource_respositories'][registered_content_item_config['resource_repository']] -%}
{%- set URI_scheme_config = pillar['system_features']['resource_repositories_configuration']['URI_prefix_schemes_configurations'][resource_repository_config['URI_prefix_scheme']] -%}

'
{{- resource_repository_config['URI_prefix_scheme'] -}}
/
{{- resource_repository_config['rel_resource_symlink_base_dir_path'] -}}
/
{{- resource_repository_config['resource_symlink_basename'] -}}
/
{{- registered_content_item_config['item_parent_dir_path'] -}}
/
{{- registered_content_item_config['item_base_name'] -}}
'

{%- endmacro -%}

###############################################################################

{%- macro get_registered_content_item_hash(
        registered_content_item_id
    )
-%}

{%- set registered_content_item_config = pillar['registered_content_items'][registered_content_item_id] -%}

'
{{- registered_content_item_config['item_content_hash'] -}}
'

{%- endmacro -%}


###############################################################################
# EOF
###############################################################################

