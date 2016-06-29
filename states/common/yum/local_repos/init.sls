#

{% if grains['kernel'] == 'Linux' %}
{% set config_temp_dir = pillar['posix_config_temp_dir'] %}
{% endif %}
{% if grains['kernel'] == 'Windows' %}
{% set config_temp_dir = pillar['windows_config_temp_dir'] %}
{% endif %}

###############################################################################
# [[[ Any Linux
{% if not grains['os_platform_type'].startswith('win') %}


{% for repo_name in pillar['system_features']['yum_repos_configuration']['yum_repositories'].keys() %}
{% for os_platform in pillar['system_features']['yum_repos_configuration']['yum_repositories'][repo_name]['os_platform_configs'].keys() %}
{% set repo_config = pillar['system_features']['yum_repos_configuration']['yum_repositories'][repo_name]['os_platform_configs'][os_platform] %}

{% if 'rsync_mirror_source' in repo_config %}

yum_repo_url_file_{{ repo_name }}_{{ os_platform }}:
    file.managed:
        - name: '{{ config_temp_dir }}/local_repos/{{ repo_name }}/{{ os_platform }}/rsync_mirror_source'
        - makedirs: True
        - contents: {{ repo_config['rsync_mirror_source'] }}
        - user: root
        - group: root
        - mode: 644
        - template: jinja

{% endif %}

{% endfor %}
{% endfor %}

# TODO: Deploy script which syncs local mirrors.

{% endif %} # os_platform_type
# ]]]
###############################################################################

