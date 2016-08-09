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

{% if pillar['properties']['parent_repo_name'] %}
# Parent repo is defined and it is the first.
{% set repo_list = [ pillar['properties']['parent_repo_name'] ] + pillar['system_features']['deploy_environment_sources']['source_repositories'].keys() %}
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
{% from 'common/libs/repo_config_queries.lib.sls' import get_repository_id_by_role with context %}
{% set override_pillars_repo_id = get_repository_id_by_role('source_profile_pillars_role') %}
{% set repo_config = pillar['system_features']['deploy_environment_sources']['source_repositories'][override_pillars_repo_id]['git'] %}
REPO_PATH="{{ get_system_host_primary_user_posix_home(repo_config['source_system_host']) }}/{{ repo_config['origin_uri_ssh_path'] }}"
echo "Make sure dynamic build descriptor is not overwritten within pillars repository." 1>&2
echo "This file must not exists: ${REPO_PATH}/pillars/profile/dynamic_build_descriptor.yaml" 1>&2
! ls -lrt "${REPO_PATH}/pillars/profile/dynamic_build_descriptor.yaml"

{#############################################################################}

{% for repo_name in repo_list %}
{% set repo_config = pillar['system_features']['deploy_environment_sources']['source_repositories'][repo_name]['git'] %}

REPO_PATH="{{ get_system_host_primary_user_posix_home(repo_config['source_system_host']) }}/{{ repo_config['origin_uri_ssh_path'] }}"

# Visual marker.
echo "################################################################################"
echo "######################################## {{ repo_name }}"
echo "######################################## -> ${REPO_PATH}"

cd "${REPO_PATH}"

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
# HEAD value means that repository is at detached head.
test "${CURRENT_BRANCH}" != "HEAD"

# It is better to use build branches (instead of latest commits).
# The problem is that latest commits are only updated until transfer
# of dynamic bulid descriptor is done. After that, updates to dynamic build
# descriptor continue inside build history repository while
# copy in the pillars stays the same.
export BUILD_BRANCH="{{ pillar['dynamic_build_descriptor']['build_branches'][repo_name] }}"

# NOTE: There are different build branches to consider.
#
#       It is crucial to understand that there are to information sources
#       for build branches:
#       *   current build branches in local Git repositories
#           (created for the pipeline)
#       *   those build branches which are accessible via pillar
#           (recorded in dynamic build descriptor transferred before).
#
#       Consistency between them must be ensured.
#       New build branches are supposed to be based on those in
#       the dynamic build descriptor.
test "${CURRENT_BRANCH}" == "${BUILD_BRANCH}"

# Retrieve version name and number.
{% set project_version_name_key = pillar['properties']['project_name'] +'_version_name' %}
{% set project_version_number_key = pillar['properties']['project_name'] + '_version_number' %}
export PROJECT_VERSION_NAME="{{ pillar['dynamic_build_descriptor'][project_version_name_key] }}"
export PROJECT_VERSION_NUMBER="{{ pillar['dynamic_build_descriptor'][project_version_number_key] }}"

# Make sure `is_release` is set to `true`.
# Otherwise, it does not make sense to merge
# the release which is not a release.
export IS_RELEASE="{{ pillar['dynamic_build_descriptor']['is_release'] }}"
test "${IS_RELEASE}" == "TRUE"

{% if repo_name in pillar['system_features']['deploy_environment_sources']['repository_roles']['build_history_role'] %}
# TODO: Make branch name generic (configurable or
#       available in dynamic build descriptor) for `build_history_role`.
# Use hardcoded default branch `develop` for `build_history_role`.
export TARGET_UPSTREAM_BRANCH="develop"
{% else %}
export TARGET_UPSTREAM_BRANCH="{{ pillar['dynamic_build_descriptor']['required_branches'][repo_name] }}"
{% endif %}

# Report branches to be compared.
echo "BUILD_BRANCH:          ${BUILD_BRANCH}"
echo "TARGET_UPSTREM_BRANCH: ${TARGET_UPSTREAM_BRANCH}"

# Reset repositories and test that there is no local modifications.
# NOTE: Without `add --all` `diff-index` will not notice untracked files.
git add --all
# NOTE: We ignore any changes in submodules
# (but we check every repository anyway).
git diff-index --ignore-submodules=all --exit-code HEAD
# Reset any staged data.
git reset 1> /dev/null

# Switch to the merge target branch.
git checkout "${TARGET_UPSTREAM_BRANCH}"

# Check that merge source branch exists.
git rev-parse --verify "${BUILD_BRANCH}" 1> /dev/null

# Check if there is BUILD_BRANCH is not merged into TARGET_UPSTREAM_BRANCH.
# The `--no-merged` option lists branches which are not merged and we
# simply look for them in the output.
set +e
git branch --no-merged "${TARGET_UPSTREAM_BRANCH}" | grep "${BUILD_BRANCH}" 1> /dev/null
RET_VAL="${?}"
set -e

# Report if there is anything to merge.
if [ "${RET_VAL}" == "0" ]
then
    echo TO_BE_MERGED
    echo "<<<<<<< INSTRUCTIONS"
    echo "        cd '${REPO_PATH}'"
    echo "        git checkout '${TARGET_UPSTREAM_BRANCH}'"
    echo "        git merge --no-ff --no-commit '${BUILD_BRANCH}'"
    echo "        # "
    echo "        # NOTE: Review merged content and commit with YOUR_EMAIL='First Last<first.last@example.com>'"
    echo "        git commit --author=YOUR_EMAIL -m 'Merge ${PROJECT_VERSION_NAME}-${PROJECT_VERSION_NUMBER}'"
    echo "        # "
    echo "        # Switch back to the build branch."
    echo "        git checkout '${BUILD_BRANCH}'"
    echo ">>>>>>> "
else
    echo SKIP
fi

# Switch back to the build branch.
git checkout "${BUILD_BRANCH}"

cd - 1> /dev/null

{% endfor %}

###############################################################################
# EOF
###############################################################################

