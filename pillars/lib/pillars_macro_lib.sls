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

{% macro filter_assigned_hosts_by_minion_hosts_enabled_in_properties(assigned_minion_list, props) %}
            [
{% for selected_minion_id in assigned_minion_list %}
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
# EOF
###############################################################################

