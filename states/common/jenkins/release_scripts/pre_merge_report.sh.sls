#!/bin/sh
###############################################################################

# This script provides automatic report about necessety to merge
# latest commits on (release) build branches.
# This is important to make these commits parent of upstream development
# so that they are not garbage collected.

###############################################################################

set -e
set -u

###############################################################################

{% if pillar['parent_repo_name'] %}
# Parent repo is defined and it is the first.
{% set repo_list = [ pillar['parent_repo_name'] ] + pillar['system_features']['deploy_environment_sources']['source_repositories'].keys() %}
{% else %}
# This profile does not define parent repo.
{% set repo_list = pillar['system_features']['deploy_environment_sources']['source_repositories'].keys() %}
{% endif %}

{#############################################################################}

{% set pillars_repo_list =
    pillar['system_features']['deploy_environment_sources']['repository_roles']['source_profile_pillars_role']
    +
    pillar['system_features']['deploy_environment_sources']['repository_roles']['target_profile_pillars_role']
%}

{#############################################################################}

{% from 'common/libs/host_config_queries.sls' import get_system_host_primary_user_posix_home with context %}

###############################################################################
# Make sure source pillars do not override dynamic build descriptor.
# This is required because merge report uses its information to
# see what branches hasn't been merged yet.

# TODO

{#############################################################################}

{% for repo_name in repo_list %}
{% set repo_config = pillar['system_features']['deploy_environment_sources']['source_repositories'][repo_name]['git'] %}

REPO_PATH="{{ get_system_host_primary_user_posix_home(repo_config['source_system_host']) }}/{{ repo_config['origin_uri_ssh_path'] }}"

cd "${REPO_PATH}"

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
# HEAD value means that repository is at detached head.
test "${CURRENT_BRANCH}" != "HEAD"

# Isn't it better to use build branches (instead of latest commits).
# The problem is that latest commits are only updated until transfer
# of dynamic bulid descriptor is done. After that, updates continue
# to build history repository while copy in the pillars stays the same.
export LATEST_COMMIT_ID="{{ pillar['dynamic_build_descriptor']['latest_commit_ids'][repo_name] }}"

{% if repo_name in pillar['system_features']['deploy_environment_sources']['repository_roles']['build_history_role'] %}
# Use hardcoded default branch `develop` for `build_history_role`.
export TARGET_UPSTREAM_BRANCH="develop"
{% else %}
export TARGET_UPSTREAM_BRANCH="{{ pillar['dynamic_build_descriptor']['required_branches'][repo_name] }}"
{% endif %}

# Reset repositories and test that there is no local modifications.
# TODO

# Switch to the branch.
git checkout "${TARGET_UPSTREAM_BRANCH}"

git rev-parse --verify "${LATEST_COMMIT_ID}"

# Check if there is anything to merge from LATEST_COMMIT_ID to TARGET_UPSTREAM_BRANCH.
set +e
git branch --no-merged "${TARGET_UPSTREAM_BRANCH}" "${LATEST_COMMIT_ID}" | grep "${LATEST_COMMIT_ID}"
RET_VAL="${?}"
set -e

# Report if there is anything to merge.
if [ "${RET_VAL}" == "0" ]
then
    echo TOBEMERGED
else
    echo SKIP
fi

# Switch back.
git checkout "${CURRENT_BRANCH}"

cd -

{% endfor %}

###############################################################################
# EOF
###############################################################################

