# Make sure correct source links are set up for Salt master.

###############################################################################
# <<<
{% if grains['os'] in [ 'Fedora', 'RedHat', 'CentOS' ] %}

{% if grains['id'] in pillar['system_host_roles']['controller_role']['assigned_hosts'] %}

# Ensure links exist and point to the source repository on Salt master.
{% if pillar['system_features']['ensure_source_links']['feature_enabled'] %}

{% set config_temp_dir = pillar['posix_config_temp_dir'] %}

'{{ config_temp_dir }}/ensure_source_link.sh':
    file.managed:
        - source: salt://common/source_links/ensure_source_link.sh
        #- template: jinja
        - makedirs: True
        - dir_mode: 755
        - user: root
        - group: root
        - mode: 744

{% for link_config_name in pillar['system_features']['ensure_source_links']['source_links'].keys() %}

{% set link_config = pillar['system_features']['ensure_source_links']['source_links'][link_config_name] %}
{% set repo_name = link_config['repo_name'] %}
{% set repo_type = pillar['system_features']['deploy_environment_sources']['source_repo_types'][repo_name] %}
{% set salt_master_local_path_base = pillar['system_features']['deploy_environment_sources']['source_repositories'][repo_name][repo_type]['salt_master_local_path_base'] %}
{% set salt_master_local_path_rest = pillar['system_features']['deploy_environment_sources']['source_repositories'][repo_name][repo_type]['salt_master_local_path_rest'] %}
{% set salt_master_local_path = salt_master_local_path_base + salt_master_local_path_rest %}

'{{ salt_master_local_path }}_{{ link_config_name }}':
    file.directory:
        - name: '{{ salt_master_local_path }}'
        - makedirs: False

ensure_source_link_{{ link_config_name }}_cmd:
    cmd.run:
        - name: '{{ config_temp_dir }}/ensure_source_link.sh "{{ salt_master_local_path }}" "{{ link_config['link_path'] }}" "{{ link_config['target_path'] }}"'
        - require:
            - file: '{{ config_temp_dir }}/ensure_source_link.sh'
            - file: '{{ salt_master_local_path }}_{{ link_config_name }}'

{% endfor %}

{% endif %}

{% endif %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

{% endif %}
# >>>
###############################################################################


