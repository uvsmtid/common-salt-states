# Orchestrate `sudo` configuration.

###############################################################################
# HEADER
###############################################################################

{% set flag_name = 'sudo_configured' %}

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
            'configure_sudo_for_required_users',
        ]
    )
}}

###############################################################################
# START: Orchestratioin logic
###############################################################################

# Applies only when feature is enabled.
{% if pillar['system_features']['configure_sudo_for_specified_users']['feature_enabled'] %}

{% set salt_master_role_host = pillar['system_host_roles']['salt_master_role']['assigned_hosts'][0] %}

configure_sudo_for_required_users:
    salt.state:
        - tgt: '*'
        - sls: common.sudo.configure_required_users
        - require:
            {{ stage_flag_file_prerequisites(flag_name) }}

{%endif %}

###############################################################################
# END
###############################################################################


