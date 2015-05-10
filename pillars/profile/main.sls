
###############################################################################
# Master configuration file should contain similar data structure:
#     this_system_keys:
#         project: project_name
#
# See also:
#   https://github.com/saltstack/salt/issues/12916
{% set project     = salt['config.get']('this_system_keys:project') %}

# Setting key `this_pillar` allows the pillar being loaded loading other
# pillar files relatively.
# See also:
#   https://github.com/saltstack/salt/issues/8875#issuecomment-89441029

include:

    # Load common pillars.
    - profile.common:
        defaults:
            this_pillar: profile.common

{% if 'project_name' == project %}

    # Load project-specific pillars.
    - profile.project_name:
        defaults:
            this_pillar: profile.project_name

{% endif %}

###############################################################################
# EOF
###############################################################################

