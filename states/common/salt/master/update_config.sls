# Salt (online) master configuration file.

{% if grains['id'] in pillar['system_host_roles']['controller_role']['assigned_hosts'] %}

###############################################################################
# <<< Any RedHat-originated OS
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

{% set resources_macro_lib = 'common/resource_symlinks/resources_macro_lib.sls' %}
{% from resources_macro_lib import get_URI_scheme_abs_links_base_dir_path_from_pillar with context %}

{% set is_generic_profile = pillar['is_generic_profile'] %}
{% set project_name = pillar['project_name'] %}
{% set profile_name = pillar['profile_name'] %}
{% set master_minion_id = pillar['master_minion_id'] %}
{% set default_username = pillar['default_username'] %}
{% set current_task_branch = pillar['current_task_branch'] %}
{% set load_bootstrap_target_envs = pillar['load_bootstrap_target_envs'] %}

/etc/salt/master:
    file.managed:
        - source: salt://common/salt/master/master.conf
        - template: jinja
        - context:
            auto_accept: {{ pillar['system_features']['target_bootstrap_configuration']['target_minion_auto_accept'] }}
            is_generic_profile: {{ is_generic_profile }}
            project_name: {{ project_name }}
            profile_name: {{ profile_name }}
            master_minion_id: {{ master_minion_id }}
            default_username: {{ default_username }}
            current_task_branch: {{ current_task_branch }}
            resources_links_dir: '{{ get_URI_scheme_abs_links_base_dir_path_from_pillar('salt://', pillar) }}'
            load_bootstrap_target_envs: {{ load_bootstrap_target_envs }}
        - user: root
        - group: root
        - mode: 644

{% endif %}
# >>>
###############################################################################

{% endif %}

