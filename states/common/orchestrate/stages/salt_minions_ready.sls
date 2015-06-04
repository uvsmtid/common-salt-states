# This is supposed to be manual stage to make sure all minions are ready.

###############################################################################
# HEADER
###############################################################################

{% set flag_name = 'salt_minions_ready' %}

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
            'minions_refresh_pillar',
            'configure_minions_on_all_minions',
            'minions_sync_all',
            'primary_configuration_for_all_minions',
        ]
    )
}}

###############################################################################
# START: Orchestratioin logic
###############################################################################

{% set controller_role_host = pillar['system_host_roles']['controller_role']['assigned_hosts'][0] %}

# For some reasons state `configure_minions_on_all_minions` may
# fail if `saltutil.refresh_pillar` is not called before.
minions_refresh_pillar:
    salt.function:
        - name: saltutil.refresh_pillar
        - tgt: '*'

configure_minions_on_all_minions:
    salt.state:
        - tgt: '*'
        - sls:
            - common.salt.minion
        - require:
            - salt: minions_refresh_pillar
            {{ stage_flag_file_prerequisites(flag_name) }}

minions_sync_all:
    salt.function:
        - name: saltutil.sync_all
        - tgt: '*'
        - require:
            - salt: configure_minions_on_all_minions

primary_configuration_for_all_minions:
    salt.state:
        - tgt: '*'
        - sls:
            - common.orchestrate.wraps.primary
        - require:
            - salt: minions_sync_all
            {{ stage_flag_file_prerequisites(flag_name) }}


###############################################################################
# END
###############################################################################


