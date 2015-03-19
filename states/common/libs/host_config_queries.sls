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
# get_system_host_primary_user_posix_home

{%- macro get_system_host_primary_user_posix_home_from_pillar(
        system_host_id
        ,
        pillar_data
    )
-%}

{%- set selected_host_config = pillar_data['system_hosts'][system_host_id] -%}

{{- selected_host_config['primary_user']['posix_user_home_dir'] -}}

{%- endmacro -%}

#------------------------------------------------------------------------------

{%- macro get_system_host_primary_user_posix_home(
        system_host_id
    )
-%}

{{- get_system_host_primary_user_posix_home_from_pillar(system_host_id, pillar) -}}

{%- endmacro -%}

###############################################################################
# is_network_checks_allowed

{%- macro is_network_checks_allowed(
        system_host_id
    )
-%}

{%- set selected_host_config = pillar['system_hosts'][system_host_id] -%}
{%- set bootstrap_mode = salt['config.get']('this_system_keys:bootstrap_mode') -%}

{%- if
       ( selected_host_config['consider_online_for_remote_connections'] )
       and
       ( bootstrap_mode != 'offline-minion-installer' )
-%}
True
{%- else -%}
False
{%- endif -%}


{%- endmacro -%}

###############################################################################
# EOF
###############################################################################

