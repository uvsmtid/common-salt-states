# Ping all hosts `consider_online_for_remote_connections`.

###############################################################################
# HEADER
###############################################################################

{% set flag_name = 'required_system_hosts_online' %}

# Use library of maros for stage flag files.
{% from 'common/orchestrate/stage_flag_files/lib.sls' import stage_flag_file_prerequisites_include      with context %}
{% from 'common/orchestrate/stage_flag_files/lib.sls' import stage_flag_file_prerequisites_include_self with context %}
{% from 'common/orchestrate/stage_flag_files/lib.sls' import stage_flag_file_prerequisites              with context %}
{% from 'common/orchestrate/stage_flag_files/lib.sls' import stage_flag_file_prerequisites_self         with context %}
{% from 'common/orchestrate/stage_flag_files/lib.sls' import stage_flag_file_create                     with context %}

# Include required states.
include:
    {{ stage_flag_file_prerequisites_include('common', flag_name) }}

# Stage flag file auto-creation.
{{
    stage_flag_file_create(
        flag_name,
        flag_name,
        [
            'ping_all_online_hosts_for_remote_connections',
        ]
    )
}}

###############################################################################
# START: Orchestratioin logic
###############################################################################

{% set controller_role_host = pillar['system_host_roles']['controller_role']['assigned_hosts'][0] %}

# Use single host (control host) to push the same single public key everywhere.
ping_all_online_hosts_for_remote_connections:
    salt.state:
        - tgt: '{{ controller_role_host }}'
        - sls: common.network.ping_hosts
        - require:
            {{ stage_flag_file_prerequisites(flag_name) }}

###############################################################################
# END
###############################################################################


