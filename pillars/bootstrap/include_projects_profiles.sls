#

{% set load_bootstrap_target_envs = salt['config.get']('this_system_keys:load_bootstrap_target_envs') %}
{% set profile_relative_pillars = salt['config.get']('this_system_keys:profile_relative_pillars') %}

include:

{% for project_name in load_bootstrap_target_envs.keys() %}

{% for profile_name in load_bootstrap_target_envs[project_name].keys() %}

{% for profile_relative_pillar in profile_relative_pillars %}

    # Merge all pillars listed in `profile_relative_pillars` under
    # the same pillar key - just like they are loaded for `this_system`.
    - '{{ project_name }}.profile.{{ profile_name }}.{{ profile_relative_pillar }}':
        key: '{{ project_name }}.{{ profile_name }}'

{% endfor %}

{% endfor %}

{% endfor %}

