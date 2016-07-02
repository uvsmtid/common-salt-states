#!/bin/sh

# This script compares list of all files under top-level directories
# with list of files under directories which are rsynced.
# If there is any difference, it lists them and fails.

set -o pipefail
#set -v
set -u
#set -x
set -e

UNSORTED_ITEMS="$(mktemp)"

ALL_ITEMS="$(mktemp)"
RSYNCED_ITEMS="$(mktemp)"

# Find all files under top-level directories
for TOP_LEVEL_DIR in $(find . -maxdepth 1 -mindepth 1 -type d)
do
    find "${TOP_LEVEL_DIR}" 1>> "${UNSORTED_ITEMS}"
done
cat "${UNSORTED_ITEMS}" | sed 's|/*$||g' | sort -u > "${ALL_ITEMS}"

# Find all files under rsynced directories.
# NOTE: Multiline template requires trailing escape char `\`.
for TOP_LEVEL_DIR in \
{%- for repo_name in pillar['system_features']['yum_repos_configuration']['yum_repositories'].keys() -%}
{%- for os_platform in pillar['system_features']['yum_repos_configuration']['yum_repositories'][repo_name]['os_platform_configs'].keys() -%}
{%- set repo_config = pillar['system_features']['yum_repos_configuration']['yum_repositories'][repo_name]['os_platform_configs'][os_platform] -%}
{%- if 'use_local_yum_mirrors' in repo_config and repo_config['use_local_yum_mirrors'] %}
"./{{ repo_config['rsync_mirror_local_destination_path_prefix'] }}{{ repo_config['rsync_mirror_internet_source_rel_path'] }}" \
{%- endif -%}
{%- endfor -%}
{%- endfor %}

do
    find "${TOP_LEVEL_DIR}" 1>> "${UNSORTED_ITEMS}"
done
cat "${UNSORTED_ITEMS}" | sed 's|/*$||g' | sort -u > "${RSYNCED_ITEMS}"

# Compare both lists.
set +e
diff "${ALL_ITEMS}" "${RSYNCED_ITEMS}"
RET_VAL="${?}"
set -e

echo "ALL_ITEMS: ${ALL_ITEMS}"
echo "RSYNCED_ITEMS: ${RSYNCED_ITEMS}"
wc "${ALL_ITEMS}" "${RSYNCED_ITEMS}"
sha1sum "${ALL_ITEMS}" "${RSYNCED_ITEMS}"

if [ "${RET_VAL}" != "0" ]
then
    echo "ERROR: There are unexpected differences between the two files." 1>&2
    exit 1
else
    echo "PASS: Lists of items are identical. There are no unsynced items." 1>&2
fi


