#!/bin/sh

{% if grains['kernel'] == 'Linux' %}
{% set config_temp_dir = pillar['posix_config_temp_dir'] %}
{% endif %}
{% if grains['kernel'] == 'Windows' %}
{% set config_temp_dir = pillar['windows_config_temp_dir'] %}
{% endif %}

set -u
set -e
set -x
set -v

MIRRORS_BASE_DIR="{{ pillar['system_features']['yum_repos_configuration']['local_yum_mirrors_role_content_dir'] }}"

{% for repo_name in pillar['system_features']['yum_repos_configuration']['yum_repositories'].keys() %}
{% for os_platform in pillar['system_features']['yum_repos_configuration']['yum_repositories'][repo_name]['os_platform_configs'].keys() %}
{% set repo_config = pillar['system_features']['yum_repos_configuration']['yum_repositories'][repo_name]['os_platform_configs'][os_platform] %}

{% if 'use_local_yum_mirrors' in repo_config and repo_config['use_local_yum_mirrors'] %}

echo "SYNC: repo = '{{ repo_name }}', os_platform = '{{ os_platform }}': use_local_yum_mirrors = True"

RSYNC_DST_PATH="${MIRRORS_BASE_DIR}/{{ repo_config['rsync_mirror_local_destination_path_prefix'] }}{{ repo_config['rsync_mirror_internet_source_rel_path'] }}"
mkdir -p "${RSYNC_DST_PATH}"
rsync \
    --archive \
    --recursive \
    --verbose \
    --delete \
    --progress \
    "{{ repo_config['rsync_mirror_internet_source_base_url'] }}{{ repo_config['rsync_mirror_internet_source_rel_path'] }}" \
    "${RSYNC_DST_PATH}" \
    && true

{% else %}

echo "SKIP: repo = '{{ repo_name }}', os_platform = '{{ os_platform }}': use_local_yum_mirrors = False"

{% endif %}

{% endfor %}
{% endfor %}
