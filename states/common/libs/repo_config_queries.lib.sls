# Set of macros to work with individual repository configurations.

###############################################################################
# get_repository_id_by_role

{%- macro get_repository_id_by_role_from_pillar(
        repository_role_id
        ,
        pillar_data
    )
-%}

{%- if pillar_data['system_features']['deploy_environment_sources']['repository_roles'][repository_role_id]|length != 0 -%}
{%- set repository_id = pillar_data['system_features']['deploy_environment_sources']['repository_roles'][repository_role_id][0] -%}
{{- repository_id -}}
{%- else -%}
{{- FAIL_NO_ASSIGNED_REPOSITORIES_FOR_THE_ROLE -}}
{%- endif -%}

{%- endmacro -%}

#------------------------------------------------------------------------------

{%- macro get_repository_id_by_role(
        repository_role_id
    )
-%}

{{- get_repository_id_by_role_from_pillar(repository_role_id, pillar) -}}

{%- endmacro -%}

###############################################################################

###############################################################################
# EOF
###############################################################################

