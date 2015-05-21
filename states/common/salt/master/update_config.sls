# Salt (online) master configuration file.

{% if grains['id'] in pillar['system_host_roles']['controller-role']['assigned_hosts'] %}

###############################################################################
# <<< Any RedHat-originated OS
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

{% set resources_macro_lib = 'common/resource_symlinks/resources_macro_lib.sls' %}
{% from resources_macro_lib import get_URI_scheme_abs_links_base_dir_path_from_pillar with context %}

{% set project_name = salt['config.get']('this_system_keys:project_name') %}
{% set profile_name = salt['config.get']('this_system_keys:profile_name') %}
{% set master_minion_id = salt['config.get']('this_system_keys:master_minion_id') %}
{% set load_bootstrap_target_envs = salt['config.get']('this_system_keys:load_bootstrap_target_envs') %}

/etc/salt/master:
    file.managed:
        - source: salt://common/salt/master/master.conf
        - template: jinja
        - context:
            auto_accept: {{ pillar['system_features']['target_bootstrap_configuration']['target_minion_auto_accept'] }}
            project_name: {{ project_name }}
            profile_name: {{ profile_name }}
            master_minion_id: {{ master_minion_id }}
            resources_links_dir: '{{ get_URI_scheme_abs_links_base_dir_path_from_pillar('salt://', pillar) }}'
            load_bootstrap_target_envs: {{ load_bootstrap_target_envs }}
        - user: root
        - group: root
        - mode: 644

{% endif %}
# >>>
###############################################################################

{% endif %}
