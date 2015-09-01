
###############################################################################
#

# Import properties.
# NOTE: Loading bootstrap profiles is never recursive.
#       Use absolute path to current profile to get properties.
{% set properties_path = 'profile/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set load_bootstrap_target_envs = props['load_bootstrap_target_envs'] %}
{% set project_name = props['project_name'] %}

# If no profiles in the list, avoid rendering `include`
# (which requires at least one element).
{% if load_bootstrap_target_envs.keys()|length != 0 %}

include:

{% for profile_name in load_bootstrap_target_envs.keys() %}

    - 'bootstrap.profiles.{{ profile_name }}':
        defaults:
            this_pillar: bootstrap.profiles.{{ profile_name }}
            profile_root: bootstrap.profiles.{{ profile_name }}
        key: '{{ project_name }}.{{ profile_name }}'

{% endfor %}

{% endif %}

###############################################################################
# EOF
###############################################################################

