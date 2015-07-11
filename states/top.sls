###############################################################################
# Salt top file for states.

base:

    '*':

        # This state file is supposed to be a symlink to `main.sls`
        # in the root of `states` directory for specific project.
        - main

###############################################################################
# EOF
###############################################################################

