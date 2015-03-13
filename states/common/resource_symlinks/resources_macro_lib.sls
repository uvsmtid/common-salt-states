# Set of macros to work with resources.

###############################################################################

{%- macro get_registered_content_item_URI(
        registered_content_item_id
    )
-%}

{%- set registered_content_item_config = pillar['registered_content_items'][registered_content_item_id] -%}
{%- set resource_repository_config = pillar['system_features']['resource_repositories_configuration']['resource_respositories'][registered_content_item_config['resource_repository']] -%}
{%- set URI_scheme_config = pillar['system_features']['resource_repositories_configuration']['URI_prefix_schemes_configurations'][resource_repository_config['URI_prefix_scheme']] -%}

{{- resource_repository_config['URI_prefix_scheme'] -}}
/
{{- resource_repository_config['rel_resource_link_base_dir_path'] -}}
/
{{- resource_repository_config['resource_link_basename'] -}}
/
{{- registered_content_item_config['item_parent_dir_path'] -}}
/
{{- registered_content_item_config['item_base_name'] -}}

{%- endmacro -%}

###############################################################################

{%- macro get_registered_content_item_hash(
        registered_content_item_id
    )
-%}

{%- set registered_content_item_config = pillar['registered_content_items'][registered_content_item_id] -%}

{{- registered_content_item_config['item_content_hash'] -}}

{%- endmacro -%}

###############################################################################

{%- macro get_URI_scheme_abs_links_base_dir_path(
        URI_prefix_scheme
    )
-%}

{%- set URI_prefix_scheme_configuration = pillar['system_features']['resource_repositories_configuration']['URI_prefix_schemes_configurations'][URI_prefix_scheme] -%}

{{- URI_prefix_scheme_configuration['abs_resource_links_base_dir_path'] -}}

{%- endmacro -%}

###############################################################################

{%- macro get_resource_repository_target_path(
        resource_repository_id
    )
-%}

{%- set resource_repository_config = pillar['system_features']['resource_repositories_configuration']['resource_respositories'][resource_repository_id] -%}
{%- set resource_repository_target_path = resource_repository_config['abs_resource_target_base_dir_path'] + '/' + resource_repository_config['resource_target_basename'] -%}

{{- resource_repository_target_path -}}

{%- endmacro -%}

###############################################################################

{%- macro get_resource_repository_link_path(
        resource_repository_id
    )
-%}

{%- set resource_repository_config = pillar['system_features']['resource_repositories_configuration']['resource_respositories'][resource_repository_id] -%}
{%- set resource_repository_config_URI_prefix_scheme = resource_repository_config['URI_prefix_scheme'] -%}
{%- set URI_prefix_scheme_configuration = pillar['system_features']['resource_repositories_configuration']['URI_prefix_schemes_configurations'][resource_repository_config_URI_prefix_scheme] -%}

{%- set URI_scheme_abs_links_base_dir_path = URI_prefix_scheme_configuration['abs_resource_links_base_dir_path'] -%}
{%- set rel_resource_link_path = resource_repository_config['rel_resource_link_base_dir_path'] + resource_repository_config['resource_link_basename'] -%}

{{- URI_scheme_abs_links_base_dir_path -}}
/
{{- rel_resource_link_path -}}

{%- endmacro -%}

###############################################################################
# EOF
###############################################################################

