# Set of macros to work with pillars.

###############################################################################
# Macro to filter list of assigned minions by `enabled_minion_hosts`.
# TODO: This is a hacky macro.
#       The output is indented according to assumed position in
#       Jinja template, specifically:
#           system_host_roles:
#               name_role:
#                   assigned_hosts:
#                       {# filter_assigned_hosts_by_enabled_minion_hosts #}

{% macro filter_assigned_hosts_by_minion_hosts_enabled_in_properties(assigned_minions_list, props) %}
            [
{% for selected_minion_id in assigned_minions_list %}
{% if selected_minion_id in props['enabled_minion_hosts'].keys() %}
                {{ selected_minion_id }}
{% if not loop.last %}
                ,
{% endif %}
{% endif %}
{% endfor %}
            ]
{% endmacro %}

###############################################################################
# This macro is related to
# `filter_assigned_hosts_by_minion_hosts_enabled_in_properties`
# but it is used specifically in `salt_minion_role` to list only
# minion hosts which are also enabled in the properties.

{% macro list_enabled_salt_managed_minions(props, minions_list) %}
{% if props['use_master_minion_template_host'] %}
{% set minions_list = minions_list + [ props['master_minion_id'] ] %}
{% endif %}
            [
{% for host_id in props['enabled_minion_hosts'].keys() %}
{% if host_id in minions_list %}
                {{ host_id }}
{% if not loop.last %}
                ,
{% endif %}
{% endif %}
{% endfor %}
            ]
{% endmacro %}

###############################################################################
# EOF
###############################################################################

