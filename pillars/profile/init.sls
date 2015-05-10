
###############################################################################
# Master configuration file should contain similar data structure:
#     this_system_keys:
#         project: project_name
#
# See also:
#   https://github.com/saltstack/salt/issues/12916
{% set project     = salt['config.get']('this_system_keys:project') %}

# Setting key `this_pillar` allows current file loading other
# pillars files relatively while letting them know their relative location
# through `this_pillar` key.
#
# See also:
#   https://github.com/saltstack/salt/issues/8875#issuecomment-89441029
{% if this_pillar is not defined %}
# If `this_pillar` defined, profile is loaded as part of
# target boostrap environment (or other similar purposes).
# If `this_pillar` is undefined, profile is loaded through top file
# to profide config data for this system.
{% set this_pillar = 'profile' %}
{% endif %}


include:

    # Load common pillars.
    - {{ this_pillar }}.common:
        defaults:
            this_pillar: {{ this_pillar }}.common

{% if 'project_name' == project %}

    # Load project-specific pillars.
    - {{ this_pillar }}.project_name:
        defaults:
            this_pillar: {{ this_pillar }}.project_name

{% endif %}

###############################################################################
# EOF
###############################################################################

