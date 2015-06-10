
###############################################################################
#

{% set load_bootstrap_target_envs = salt['config.get']('this_system_keys:load_bootstrap_target_envs') %}

{% set project_name = salt['config.get']('this_system_keys:project_name') %}

include:

{% for profile_name in load_bootstrap_target_envs.keys() %}

    - 'bootstrap.profiles.{{ profile_name }}':
        defaults:
            this_pillar: bootstrap.profiles.{{ profile_name }}
            profile_root: bootstrap.profiles.{{ profile_name }}
        key: '{{ project_name }}.{{ profile_name }}'

{% endfor %}

###############################################################################
# EOF
###############################################################################

