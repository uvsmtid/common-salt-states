# Orchestrate SSH key distribution.

###############################################################################
# HEADER
###############################################################################

{% set flag_name = 'ssh_keys_distributed' %}

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
            'distribute_primary_user_ssh_private_key_everywhere',
            'distribute_primary_user_ssh_pubic_key_everywhere',
            'accept_all_ssh_host_keys_everywhere',
        ]
    )
}}

###############################################################################
# START: Orchestratioin logic
###############################################################################

{% set controller_role_host = pillar['system_host_roles']['controller_role']['assigned_hosts'][0] %}

# Use Salt file server to deploy private keys on required minions.
distribute_primary_user_ssh_private_key_everywhere:
    salt.state:
        - tgt: '*'
        - sls: common.ssh.distribute_private_keys
        - require:
            {{ stage_flag_file_prerequisites(flag_name) }}

# Use single host (control host) to push the same public keys everywhere.
# NOTE: This will also accept host keys but only on `contoller_role`.
distribute_primary_user_ssh_pubic_key_everywhere:
    salt.state:
        - tgt: '{{ controller_role_host }}'
        - sls: common.ssh.distribute_public_keys
        - require:
            {{ stage_flag_file_prerequisites(flag_name) }}

# Attempt connection on each minion to accept host keys of all other hosts.
# NOTE: This will accept host keys on each minion to each required hosts.
accept_all_ssh_host_keys_everywhere:
    salt.state:
        - tgt: '*'
        - sls: common.ssh.accept_host_keys
        - require:
            {{ stage_flag_file_prerequisites(flag_name) }}
            - salt: distribute_primary_user_ssh_private_key_everywhere
            - salt: distribute_primary_user_ssh_pubic_key_everywhere

###############################################################################
# END
###############################################################################

