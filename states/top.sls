# Salt top states file

# Master configuration file should contain similar data structure:
#     this_system_keys:
#         project: project_name
#
# See also:
#   https://github.com/saltstack/salt/issues/12916
{% set project     = salt['config.get']('this_system_keys:project') %}

# Common "header" for all projects so that minions participating in any
# project render single `base` key.
base:

    '*':

        - {{ project }}.main

###############################################################################
# EOF
###############################################################################

