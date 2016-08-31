
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set master_minion_id = props['master_minion_id'] %}

{% set pillars_macro_lib = 'lib/pillars_macro_lib.sls' %}
{% from pillars_macro_lib import filter_assigned_hosts_by_minion_hosts_enabled_in_properties with context %}

{% set host_role_id = 'local_yum_mirrors_role' %}

system_host_roles:

    {{ host_role_id }}:
        hostname: {{ host_role_id|replace("_", "-") }}
        assigned_hosts:
            {{ filter_assigned_hosts_by_minion_hosts_enabled_in_properties([
                    master_minion_id
                ], props)
            }}

###############################################################################
# EOF
###############################################################################

