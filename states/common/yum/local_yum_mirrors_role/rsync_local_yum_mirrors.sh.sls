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

CONFIG_DIR="{{ config_temp_dir }}/{{ pillar['system_features']['yum_repos_configuration']['rsync_syncer_base_dir'] }}/config"
{% set local_yum_mirrors_role_content_dir = pillar['system_features']['yum_repos_configuration']['local_yum_mirrors_role_content_dir'] %}
MIRRORS_BASE_DIR="{{ local_yum_mirrors_role_content_dir }}"

{% for repo_name in pillar['system_features']['yum_repos_configuration']['yum_repositories'].keys() %}
{% for os_platform in pillar['system_features']['yum_repos_configuration']['yum_repositories'][repo_name]['os_platform_configs'].keys() %}
{% set repo_config = pillar['system_features']['yum_repos_configuration']['yum_repositories'][repo_name]['os_platform_configs'][os_platform] %}

{% if 'use_local_yum_mirrors' in repo_config and repo_config['use_local_yum_mirrors'] %}

RSYNC_DST_PATH_PREFIX="$(cat "${CONFIG_DIR}/{{ repo_name }}/{{ os_platform }}/rsync_mirror_local_destination_path_prefix")"
RSYNC_REL_PATH="$(cat "${CONFIG_DIR}/{{ repo_name }}/{{ os_platform }}/rsync_mirror_internet_source_rel_path")"

RSYNC_SRC_BASE_URL="$(cat "${CONFIG_DIR}/{{ repo_name }}/{{ os_platform }}/rsync_mirror_internet_source_base_url")"


RSYNC_SRC_URL="${RSYNC_SRC_BASE_URL}${RSYNC_REL_PATH}"
RSYNC_DST_PATH="${MIRRORS_BASE_DIR}/${RSYNC_DST_PATH_PREFIX}${RSYNC_REL_PATH}"

mkdir -p "${RSYNC_DST_PATH}"
rsync -avrP --delete "${RSYNC_SRC_URL}" "${RSYNC_DST_PATH}"

{% endif %}

{% endfor %}
{% endfor %}

