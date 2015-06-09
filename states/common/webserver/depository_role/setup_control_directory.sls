# Configure control directory.

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

{% if pillar['system_features']['deploy_central_control_directory']['feature_enabled'] %}
{% if grains['id'] in pillar['system_host_roles']['depository_role']['assigned_hosts'] %}

{% set depository_role_content_parent_dir = pillar['system_features']['validate_depository_role_content']['depository_role_content_parent_dir'] %}

{% set repo_name = pillar['system_features']['deploy_environment_sources']['control_scripts_repo_name'] %}

include:
    - common.webserver.depository_role

setup_control_directory_recursively_from_sources:
    file.recurse:
        - name: '{{ pillar['system_features']['deploy_central_control_directory']['control_dir_fs_path'] }}'
        - source: salt://source_roots/{{ repo_name }}/{{ pillar['system_features']['deploy_central_control_directory']['control_dir_src_path'] }}
        - user: apache
        - group: apache
        - file_mode: 660
        - dir_mode: 770
        - makedirs: True
        - include_empty: True
        - clean: False
        - require:
            - file: '{{ depository_role_content_parent_dir }}/depository_role.txt'

{% endif %}
{% endif %}


{% endif %}
# >>>
###############################################################################


