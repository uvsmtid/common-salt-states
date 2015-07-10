# Handy dummy state which lists hosts required online.

{% from 'common/libs/host_config_queries.sls' import is_network_checks_allowed with context %}

{% set all_defined_host_ids = pillar['system_hosts'].keys() %}

{% for host_id in all_defined_host_ids %}

{% set host_config = pillar['system_hosts'][host_id] %}

dummy_state_show_hosts_required_online_{{ host_id }}:
    cmd.run:
        - name: "echo {{ host_id }}: {{ is_network_checks_allowed(host_id) }}"

{% endfor %}

