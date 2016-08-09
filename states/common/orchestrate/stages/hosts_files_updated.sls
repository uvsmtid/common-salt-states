# Orchestrate update of `hosts` files.

###############################################################################
# HEADER
###############################################################################

{% set flag_name = 'hosts_files_updated' %}

# Use library of maros for stage flag files.
{% from 'common/orchestrate/lib.sls' import stage_flag_file_prerequisites_include      with context %}
{% from 'common/orchestrate/lib.sls' import stage_flag_file_prerequisites_include_self with context %}
{% from 'common/orchestrate/lib.sls' import stage_flag_file_prerequisites              with context %}
{% from 'common/orchestrate/lib.sls' import stage_flag_file_prerequisites_self         with context %}
{% from 'common/orchestrate/lib.sls' import stage_flag_file_create                     with context %}

# Include required states.
include:
    {{ stage_flag_file_prerequisites_include('common', flag_name) }}

# Stage flag file auto-creation.
{{
    stage_flag_file_create(
        flag_name,
        flag_name,
        [
            'configure_hosts_files_everywhere',
        ]
    )
}}

###############################################################################
# START: Orchestratioin logic
###############################################################################

{% set salt_master_role_host = pillar['system_host_roles']['salt_master_role']['assigned_hosts'][0] %}

configure_hosts_files_everywhere:
    salt.state:
        - tgt: '*'
        - sls: common.hosts_file
        - require:
            {{ stage_flag_file_prerequisites(flag_name) }}

###############################################################################
# EOF
###############################################################################

