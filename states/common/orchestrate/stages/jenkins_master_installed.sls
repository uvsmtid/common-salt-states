# Orchestrate Jenkins master installation.

###############################################################################
# HEADER
###############################################################################

{% set flag_name = 'jenkins_master_installed' %}

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
            'configure_jenkins_master_role',
            'install_jenkins_plugins',
        ]
    )
}}

###############################################################################
# START: Orchestratioin logic
###############################################################################

# Applies only when feature is enabled.
{% if pillar['system_features']['configure_jenkins']['feature_enabled'] %}

{% set jenkins_master_role_host = pillar['system_host_roles']['jenkins-master-role']['assigned_hosts'][0] %}

configure_jenkins_master_role:
    salt.state:
        - tgt: '{{ jenkins_master_role_host }}'
        - sls: common.jenkins.master
        - require:
            {{ stage_flag_file_prerequisites(flag_name) }}

install_jenkins_plugins:
    salt.state:
        - tgt: '{{ jenkins_master_role_host }}'
        - sls: common.jenkins.cygwin
        - require:
            {{ stage_flag_file_prerequisites(flag_name) }}
            - salt: configure_jenkins_master_role

{%endif %}

###############################################################################
# END
###############################################################################

