
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
{% set is_generic_profile = salt['config.get']('this_system_keys:is_generic_profile') %}

# Setting key `this_pillar` allows current file loading other
# pillars files relatively while letting them know their relative location
# through `this_pillar` key.
#
# See also:
#   https://github.com/saltstack/salt/issues/8875#issuecomment-89441029

{% set verify_pillar_file = False %}
{% if this_pillar is not defined %}
# If `this_pillar` is undefined, (this) dir `profile` loaded through top file
# to profide config data for this system.
# In this case set `this_pillar` as `profile`.
{% set this_pillar = 'profile' %}
# In addition to that use `project_name` and `profile_name` to ensure
# there is a matching pillar file.
{% set verify_pillar_file = True %}
{% else %}
# If `this_pillar` defined, `profile` is loaded as part of
# target bootstrap environment (or other similar purposes).
{% endif %}

include:

    # Make sure file which specify which pillar it is exists.
{% if verify_pillar_file %}
    # The following file should be consciously created to make sure
    # links to pillar repository is actually set correctly.
    # This file highlights difference between two profiles during comparision.
{% if is_generic_profile %}
    - {{ this_pillar }}.project_name-{{ project_name }}
{% else %}
    - {{ this_pillar }}.project_name-{{ project_name }}
    - {{ this_pillar }}.profile_name-{{ profile_name }}
{% endif %}
{% endif %}

    # Load common pillars.
    - {{ this_pillar }}.common:
        defaults:
            this_pillar: {{ this_pillar }}.common

    - {{ this_pillar }}.bootstrap:
        defaults:
            this_pillar: {{ this_pillar }}.bootstrap

{% if 'project_name' == project_name %}

    # Load `project_name`-specific pillars.
    - {{ this_pillar }}.{{ project_name }}:
        defaults:
            this_pillar: {{ this_pillar }}.{{ project_name }}

{% endif %}

###############################################################################
# EOF
###############################################################################

