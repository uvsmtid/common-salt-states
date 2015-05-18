# Final stage.

###############################################################################
# HEADER
###############################################################################

{% set flag_name = 'stop' %}

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
            'run_highstate_on_all_minions',
        ]
    )
}}

###############################################################################
# START: Orchestratioin logic
###############################################################################

run_highstate_on_all_minions:
    salt.state:
        - tgt: '*'
        # DO not run `highstate` because default is test=True.
        # TODO: How to force this `highstate` to run with test=False?
        - highstate: False
        - sls:
            - common.dummy
        - require:
            {{ stage_flag_file_prerequisites(flag_name) }}

###############################################################################
# END
###############################################################################


