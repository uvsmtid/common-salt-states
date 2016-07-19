
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set master_minion_id = props['master_minion_id'] %}

{% set pillars_macro_lib = 'lib/pillars_macro_lib.sls' %}
{% from pillars_macro_lib import filter_assigned_hosts_by_minion_hosts_enabled_in_properties with context %}

system_host_roles:

    wildfly_node_1_role:
        hostname: wildfly-node-1-role
        assigned_hosts:
            {{ filter_assigned_hosts_by_minion_hosts_enabled_in_properties([
                ], props)
            }}

###############################################################################
# EOF
###############################################################################

