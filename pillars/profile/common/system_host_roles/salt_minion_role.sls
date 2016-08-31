
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set master_minion_id = props['master_minion_id'] %}

{% set pillars_macro_lib = 'lib/pillars_macro_lib.sls' %}
{% from pillars_macro_lib import list_enabled_salt_managed_minions with context %}

# Load minion list.
{% set minions_list_path = profile_root.replace('.', '/') + '/common/system_hosts/minions_list.yaml' %}
{% import_yaml minions_list_path as minions_list %}

{% set host_role_id = 'salt_minion_role' %}

system_host_roles:

    {{ host_role_id }}:
        hostname: {{ host_role_id|replace("_", "-") }}
        assigned_hosts:
            {{ list_enabled_salt_managed_minions(props, minions_list) }}

###############################################################################
# EOF
###############################################################################

