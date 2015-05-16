
###############################################################################
# Master configuration file should contain similar data structure:
#     this_system_keys:
#         project_name: project_name
#         profile_name: profile_name
#
# See also:
#   https://github.com/saltstack/salt/issues/12916
{% set project_name = salt['config.get']('this_system_keys:project_name') %}
{% set profile_name = salt['config.get']('this_system_keys:profile_name') %}

# Setting key `this_pillar` allows current file loading other
# pillars files relatively while letting them know their relative location
# through `this_pillar` key.
#
# See also:
#   https://github.com/saltstack/salt/issues/8875#issuecomment-89441029
{% if this_pillar is not defined %}
# If `this_pillar` defined, profile_name is loaded as part of
# target boostrap environment (or other similar purposes).
# If `this_pillar` is undefined, dir `profile` loaded through top file
# to profide config data for this system.
{% set this_pillar = 'profile' %}
{% endif %}


include:

    # Load common pillars.
    - {{ this_pillar }}.common:
        defaults:
            this_pillar: {{ this_pillar }}.common

    - {{ this_pillar }}.bootstrap:
        defaults:
            this_pillar: {{ this_pillar }}.bootstrap

{% if 'project_name' == project_name %}

    # Load project_name-specific pillars.
    - {{ this_pillar }}.project_name:
        defaults:
            this_pillar: {{ this_pillar }}.project_name

{% endif %}

###############################################################################
# EOF
###############################################################################

