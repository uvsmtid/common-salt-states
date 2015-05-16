###############################################################################
# Salt top file for states.

# Configuration file should contain similar data structure:
#     this_system_keys:
#         project_name: project_name
#
# See also:
#   https://github.com/saltstack/salt/issues/12916
{% set project_name = salt['config.get']('this_system_keys:project_name') %}

base:

    '*':

        - {{ project_name }}.main

###############################################################################
# EOF
###############################################################################

