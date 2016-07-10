# Final stage.

###############################################################################
# HEADER
###############################################################################

{% set flag_name = 'orchestrate_stage_stop' %}

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
        # Do not run `highstate`. Run it explicitly, if required.
        # At the moment, this file configures `orchestrate`
        # to bring up the system into initially working condition.
        # More over, it will fail if default minion config is test=True.
        # TODO: How to force this `highstate` to run with test=False?
        # See:
        #   https://github.com/saltstack/salt/issues/24209
        #   https://groups.google.com/forum/#!topic/salt-users/pKt_1m9Y40Q
        - highstate: False
        - sls:
            - common.dummy
        - require:
            {{ stage_flag_file_prerequisites(flag_name) }}

###############################################################################
# END
###############################################################################


