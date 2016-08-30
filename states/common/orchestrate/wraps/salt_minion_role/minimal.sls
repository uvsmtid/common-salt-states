# Minimal configuration for `salt_minion_role` role (Salt minion).

{% if 'salt_minion_role' in pillar['system_host_roles'] %}

{% if grains['id'] in pillar['system_host_roles']['salt_minion_role']['assigned_hosts'] %}

include:

    {% set hostname_res = pillar['system_features']['hostname_resolution_config'] %}

    {% if hostname_res['hostname_resolution_type'] == 'static_hosts_file' %}

    # Generate hosts files on minions.
    - common.hosts_file

    {% endif %}

    - common.hostname

{% endif %}

{% endif %}

