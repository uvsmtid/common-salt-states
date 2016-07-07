# Orchestrate configuration of yum repositories.

###############################################################################
# HEADER
###############################################################################

{% set flag_name = 'yum_repositories_configured' %}

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
            'configure_yum_repositories_everywhere',
        ]
    )
}}

###############################################################################
# START: Orchestratioin logic
###############################################################################

{% set controller_role_host = pillar['system_host_roles']['controller_role']['assigned_hosts'][0] %}

configure_yum_repositories_everywhere:
    salt.state:
        - tgt: '*'
        - sls: common.yum
        - require:
            {{ stage_flag_file_prerequisites(flag_name) }}

###############################################################################
# END
###############################################################################

