#!/bin/sh

{% if grains['kernel'] == 'Linux' %}
{% set config_temp_dir = pillar['posix_config_temp_dir'] %}
{% endif %}
{% if grains['kernel'] == 'Windows' %}
{% set config_temp_dir = pillar['windows_config_temp_dir'] %}
{% endif %}

set -v
set -u
set -e
set -x

MIRRORS_BASE_DIR="{{ pillar['system_features']['yum_repos_configuration']['local_yum_mirrors_role_content_dir'] }}"

{% for repo_name in pillar['system_features']['yum_repos_configuration']['yum_repositories'].keys() %}
{% for os_platform in pillar['system_features']['yum_repos_configuration']['yum_repositories'][repo_name]['os_platform_configs'].keys() %}
{% set repo_config = pillar['system_features']['yum_repos_configuration']['yum_repositories'][repo_name]['os_platform_configs'][os_platform] %}

{% if 'use_local_yum_mirrors' in repo_config and repo_config['use_local_yum_mirrors'] %}

echo "SYNC: repo = '{{ repo_name }}', os_platform = '{{ os_platform }}': use_local_yum_mirrors = True"

RSYNC_DST_PATH="${MIRRORS_BASE_DIR}/{{ repo_config['rsync_mirror_local_destination_path_prefix'] }}{{ repo_config['rsync_mirror_internet_source_rel_path'] }}"
RSYNC_SRC_PATH="{{ repo_config['rsync_mirror_internet_source_base_url'] }}{{ repo_config['rsync_mirror_internet_source_rel_path'] }}"

# Make sure trailing character is `/`
# (for `rsync` to avoid creating subdirectories).
# See: http://stackoverflow.com/a/21635778/441652
for RSYNC_PATH in "${RSYNC_SRC_PATH}" "${RSYNC_DST_PATH}"
do
    if [ "${RSYNC_PATH: -1}" != "/" ]
    then
        echo "ERROR: trailing character is not \`/\`: ${RSYNC_PATH}"
        exit 1
    fi
done

# NOTE: Use this `true`<->`false` switch for manual script changes if require.
if true
then

mkdir -p "${RSYNC_DST_PATH}"
# NOTE: Option `--archive` is removed - we do not care about attributes.
#    --archive \
#    --delete \
rsync \
    --recursive \
    --verbose \
    --progress \
    "${RSYNC_SRC_PATH}" \
    "${RSYNC_DST_PATH}" \
    && true

fi

{% else %}

echo "SKIP: repo = '{{ repo_name }}', os_platform = '{{ os_platform }}': use_local_yum_mirrors = False"

{% endif %}

{% endfor %}
{% endfor %}

