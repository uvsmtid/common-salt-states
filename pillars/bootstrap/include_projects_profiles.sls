#

{% set bootstrap_target_envs = salt['config.get']('this_system_keys:bootstrap_target_envs') %}

include:

{% for project_name in bootstrap_target_envs.keys() %}

{% for profile_name in bootstrap_target_envs[project_name].keys() %}

    - '{{ project_name }}.profile.{{ profile_name }}':
        key: '{{ project_name }}.{{ profile_name }}'

{% endfor %}

{% endfor %}


