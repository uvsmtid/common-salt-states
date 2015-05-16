#

{% set load_bootstrap_target_envs = salt['config.get']('this_system_keys:load_bootstrap_target_envs') %}

{% set project_name = salt['config.get']('this_system_keys:project_name') %}

include:

{% for profile_name in load_bootstrap_target_envs.keys() %}

    - 'bootstrap.pillars.{{ profile_name }}.profile':
        defaults:
            this_pillar: bootstrap.pillars.{{ profile_name }}.profile
        key: '{{ project_name }}.{{ profile_name }}'

{% endfor %}

