# Set of macros to work with individual host configurations.

###############################################################################
# get_host_id_by_role

{%- macro get_host_id_by_role_from_pillar(
        host_role_id
        ,
        pillar_data
    )
-%}

{%- if pillar_data['system_host_roles'][host_role_id]['assigned_hosts']|length != 0 -%}
{%- set host_id = pillar_data['system_host_roles'][host_role_id]['assigned_hosts'][0] -%}
{{- host_id -}}
{%- else -%}
{{- FAIL_NO_ASSIGNED_HOSTS_FOR_THE_ROLE -}}
{%- endif -%}

{%- endmacro -%}

#------------------------------------------------------------------------------

{%- macro get_host_id_by_role(
        host_role_id
    )
-%}

{{- get_host_id_by_role_from_pillar(host_role_id, pillar) -}}

{%- endmacro -%}

###############################################################################
# get_role_ip_address

{%- macro get_role_ip_address_from_pillar(
        host_role_id
        ,
        pillar_data
    )
-%}

{%- set selected_host_id = get_host_id_by_role_from_pillar(host_role_id, pillar_data) -%}
{%- set selected_host_config = pillar_data['system_hosts'][selected_host_id] -%}

{%- set selected_net_id = selected_host_config['defined_in'] -%}
{{- selected_host_config[selected_net_id]['ip'] -}}

{%- endmacro -%}

#------------------------------------------------------------------------------

{%- macro get_role_ip_address(
        host_role_id
    )
-%}

{{- get_role_ip_address_from_pillar(host_role_id, pillar) -}}

{%- endmacro -%}

###############################################################################
# EOF
###############################################################################
