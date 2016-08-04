
###############################################################################
# Salt top file for pillars.

base:

    '*':

        # Load `profile` directory.
        - profile

        # Load other `profile_name` for bootstrap target environments.
        - bootstrap

###############################################################################
# EOF
###############################################################################

