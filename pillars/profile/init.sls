
###############################################################################
#

# Setting key `this_pillar` allows current file loading other
# pillars files relatively while letting them know their relative location
# through `this_pillar` key.
#
# See also:
#   https://github.com/saltstack/salt/issues/8875#issuecomment-89441029

{% set verify_pillar_file = False %}
{% if profile_root is not defined %}
# If `profile_root` is undefined, (this) dir `profile` loaded through top file
# to profide config data for this system.
# In this case set `profile_root` as `profile`.
# Similar logic applies for `this_pillar` variable.
{% set profile_root = 'profile' %}
{% set this_pillar = 'profile' %}
# In addition to that use `project_name` and `profile_name` to ensure
# there is a matching pillar file.
{% set verify_pillar_file = True %}
{% else %}
# If `profile_root` defined, `profile` is loaded as part of
# target bootstrap environment (or other similar purposes) where
# `profile_root` is supposed to point to required root already.
# Similar logic applies for `this_pillar` variable.
{% endif %}

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set project_name = props['project_name'] %}
{% set profile_name = props['profile_name'] %}
{% set is_generic_profile = props['is_generic_profile'] %}

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
            profile_root: {{ profile_root }}

    # Load properities in the root of pillar profile tree.
    - {{ this_pillar }}.properties:
        defaults:
            this_pillar: {{ this_pillar }}.properties
            profile_root: {{ profile_root }}

    # Load bootstrap target pillar profiles.
    - {{ this_pillar }}.bootstrap:
        defaults:
            this_pillar: {{ this_pillar }}.bootstrap
            profile_root: {{ profile_root }}

{% if 'project_name' == project_name %}

    # Load `project_name`-specific pillars.
    - {{ this_pillar }}.{{ project_name }}:
        defaults:
            this_pillar: {{ this_pillar }}.{{ project_name }}
            profile_root: {{ profile_root }}

{% endif %}

###############################################################################
# EOF
###############################################################################

