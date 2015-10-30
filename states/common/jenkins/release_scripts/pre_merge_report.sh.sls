#!/bin/sh

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

###############################################################################

{% set pillars_repo_list =
    pillar['system_features']['deploy_environment_sources']['repository_roles']['source_profile_pillars_role']
    +
    pillar['system_features']['deploy_environment_sources']['repository_roles']['target_profile_pillars_role']
%}

###############################################################################

{% for repo_name in repo_list %}
{% set repo_config = pillar['system_features']['deploy_environment_sources']['source_repositories'][repo_name]['git'] %}

REPO_PATH="{{ get_system_host_primary_user_posix_home(repo_config['source_system_host']) }}/{{ repo_config['origin_uri_ssh_path'] }}"

cd "${REPO_PATH}"

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
# HEAD value means that repository is at detached head.
test "${CURRENT_BRANCH}" != "HEAD"

export SOURCE_BRANCH="{{ pillar['system_build_descriptor']['build_branches']['repo_name'] }}"
export TARGET_UPSTREAM_BRANCH="{{ pillar['system_build_descriptor']['required_branches']['repo_name'] }}"

# Switch to the branch.
git checkout "${TARGET_UPSTREAM_BRANCH}"

git rev-parse --verify "${SOURCE_BRANCH}"

# Check if there is anything to merge.
set +e
git branch --no-merged "${TARGET_UPSTREAM_BRANCH}" "${SOURCE_BRANCH}" | grep "${SOURCE_BRANCH}"
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
git checkout "${SOURCE_BRANCH}"

cd -

{% endif %}

{% endfor %}

###############################################################################
# EOF
###############################################################################

