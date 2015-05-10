###############################################################################
# Salt top file for states.

# Configuration file should contain similar data structure:
#     this_system_keys:
#         project: project_name
#
# See also:
#   https://github.com/saltstack/salt/issues/12916
{% set project     = salt['config.get']('this_system_keys:project') %}

base:

    '*':

        - {{ project }}.main

###############################################################################
# EOF
###############################################################################

