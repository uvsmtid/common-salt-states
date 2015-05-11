
###############################################################################
# Salt top file for pillars.

# If bootstrap is to be used,
# configuration file should contain similar data structure:
#   this_system_keys:
#       load_bootstrap_target_envs:
#           observer:
#               this_system:
#
# See also:
#   https://github.com/saltstack/salt/issues/12916
#
{% set load_bootstrap_target_envs = salt['config.get']('this_system_keys:load_bootstrap_target_envs') %}

base:

    '*':

        # Load profile.
        - profile

{% if load_bootstrap_target_envs %}

        # Load profiles for bootstrap target environments.
        - bootstrap.bootstrap_target_envs

{% endif %}

###############################################################################
# EOF
###############################################################################

