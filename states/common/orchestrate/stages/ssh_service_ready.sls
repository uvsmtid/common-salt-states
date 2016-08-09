# Install SSH server on all minions.

###############################################################################
# HEADER
###############################################################################

{% set flag_name = 'ssh_service_ready' %}

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
            'install_and_configure_ssh_server',
        ]
    )
}}

###############################################################################
# START: Orchestratioin logic
###############################################################################

install_and_configure_ssh_server:
    salt.state:
        - tgt: '*'
        - sls: common.ssh
        - require:
            {{ stage_flag_file_prerequisites(flag_name) }}

###############################################################################
# EOF
###############################################################################

