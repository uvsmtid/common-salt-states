#!/bin/sh

###############################################################################
# This script simply makes specifying arguments to bootstrap script
# more trivial. However, it still requires conscious reviewing and selecting
# (uncommenting) required `HOST_ID` assignment.
###############################################################################

set -u
set -x
set -e
set -o pipefail

# NOTE: Set different bootstrpap use case, if required.
BOOTSTRAP_USE_CASE=initial-online-node

# Make sure `HOST_ID` value is not inherited from environment.
# This is to make this script fail before
unset HOST_ID

{% set target_env_pillar = pillar['bootstrap_target_profile'] %}
PROJECT_NAME="{{ target_env_pillar['properties']['project_name'] }}"
PROFILE_NAME="{{ target_env_pillar['properties']['profile_name'] }}"

# NOTE: Uncomment required `HOST_ID` assignment before running the script.
#------------------------------------------------------------------------------
{% for host_id in target_env_pillar['system_hosts'].keys() %}
#HOST_ID="{{ host_id }}"
{% endfor %}
#------------------------------------------------------------------------------

python ./bootstrap.py \
    deploy \
    "${BOOTSTRAP_USE_CASE}" \
    conf/"${PROJECT_NAME}"/"${PROFILE_NAME}"/"${HOST_ID}.py" \
    2>&1 | tee bootstrap.log

RET_VAL="$?"

if [ "${RET_VAL}" != "0" ]
then
    echo "Command returned: ${RET_VAL}"
    echo "FAILURE"
else
    echo "SUCCESS"
fi

echo "Review the \`bootstrap.log\` file for any errors."

###############################################################################
# EOF
###############################################################################

