
###############################################################################
#

# Setting key `this_pillar` allows current file loading other
# pillars files relatively while letting them know their relative location
# through `this_pillar` key.
#
# See also:
#   https://github.com/saltstack/salt/issues/8875#issuecomment-89441029

{% if profile_root is not defined %}
# If `profile_root` is undefined, (this) dir `profile` loaded through top file
# to profide config data for this system.
# In this case set `profile_root` as `profile`.
# Similar logic applies for `this_pillar` variable.
{% set profile_root = 'profile' %}
{% set this_pillar = 'profile' %}
{% else %}
# If `profile_root` defined, `profile` is loaded as part of
# target bootstrap environment (or other similar purposes) where
# `profile_root` is supposed to already point to required root.
# Similar logic applies for `this_pillar` variable.
{% endif %}

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set project_name = props['project_name'] %}

include:

    # Load common pillars.
    - {{ this_pillar }}.common:
        defaults:
            this_pillar: {{ this_pillar }}.common
            profile_root: {{ profile_root }}

    # Load bootstrap target pillar profiles.
    - {{ this_pillar }}.bootstrap:
        defaults:
            this_pillar: {{ this_pillar }}.bootstrap
            profile_root: {{ profile_root }}

    # Load `project_name`-specific pillars.
    - {{ this_pillar }}.{{ project_name }}:
        defaults:
            this_pillar: {{ this_pillar }}.{{ project_name }}
            profile_root: {{ profile_root }}

    # Load properities in the root of pillar profile tree.
    - {{ this_pillar }}.common.properties:
        defaults:
            this_pillar: {{ this_pillar }}.common.properties
            profile_root: {{ profile_root }}

###############################################################################
# EOF
###############################################################################

