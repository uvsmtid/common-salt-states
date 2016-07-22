# Orchestrate Jenkins slaves connection.

###############################################################################
# HEADER
###############################################################################

{% set flag_name = 'jenkins_slaves_connected' %}

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
            'configure_jenkins_slaves',
            'configure_jenkins_nodes',
        ]
    )
}}

###############################################################################
# START: Orchestratioin logic
###############################################################################

# Applies only when feature is enabled.
{% if pillar['system_features']['configure_jenkins']['feature_enabled'] %}

{% set salt_master_role_host = pillar['system_host_roles']['salt_master_role']['assigned_hosts'][0] %}
{% set jenkins_master_role = pillar['system_host_roles']['jenkins_master_role']['assigned_hosts'][0] %}

configure_jenkins_slaves:
    salt.state:
        - tgt: '*'
        - sls: common.jenkins.slave
        - require:
            {{ stage_flag_file_prerequisites(flag_name) }}

configure_jenkins_nodes:
    salt.state:
        - tgt: '{{ jenkins_master_role }}'
        - sls: common.jenkins.node_configuration
        - require:
            {{ stage_flag_file_prerequisites(flag_name) }}
            - salt: configure_jenkins_slaves

{%endif %}

###############################################################################
# END
###############################################################################

