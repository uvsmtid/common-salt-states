
###############################################################################
# Salt top file for pillars.

base:

    '*':

        # Load `profile` directory.
        - profile

        # Load other `profile_name`s for bootstrap target environments.
        - bootstrap.bootstrap_target_envs

###############################################################################
# EOF
###############################################################################

