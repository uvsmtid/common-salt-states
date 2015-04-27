# Salt top pillars file.

# Master configuration file should contain similar data structure:
#     this_system_keys:
#         project: project_name
#
# See also:
#   https://github.com/saltstack/salt/issues/12916
{% set project = salt['config.get']('this_system_keys:project') %}
{% set load_bootstrap_target_envs = salt['config.get']('this_system_keys:load_bootstrap_target_envs') %}

# Common "header" for all projects so that minions participating in any
# project render single `base` key.
base:

    '*':

###############################################################################
# Project
###############################################################################

        # Load pillars used by project-specific states.
        - {{ project }}.main

###############################################################################
# Bootstrap target environments
###############################################################################

{% if load_bootstrap_target_envs %}

        - bootstrap.bootstrap_target_envs

{% endif %}

###############################################################################
###############################################################################
# EOF
###############################################################################

