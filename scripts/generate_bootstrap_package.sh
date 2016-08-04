#!/bin/sh
#
# This is a handy script to generate bootstrap package.
# There are two arguments:
#

set -e
set -u

# Get absolute path to the script.
# See: http://stackoverflow.com/q/4774054/441652
SCRIPT_DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

BOOTSTRAP_TARGET_PROFILE="${SALT_PROFILE_NAME}"
if [ -n "${1+x}" ]
then
    BOOTSTRAP_TARGET_PROFILE="${1}"
fi

echo "BOOTSTRAP_TARGET_PROFILE=${BOOTSTRAP_TARGET_PROFILE}" 1>&2

CHECK_SALT_OUTPUT_SCRIPT="${SCRIPT_DIR_PATH}/check_salt_output.py"

# Retrieve absolute path to repo with `bootstrap_target_profile_pillars`:
BOOTSTRAP_TARGET_PROFILE_REPO="$(sudo salt-call --out txt pillar.get repo_path_bootstrap_target_profile_pillars | cut -d' ' -f2)"

# Checkout required branch within repository.
cd "${BOOTSTRAP_TARGET_PROFILE_REPO}"
git checkout "${BOOTSTRAP_TARGET_PROFILE}"
cd -

# Run bootstrap generation.
sudo salt-call \
    --out json \
    state.sls bootstrap.generate_content \
    test=False | tee salt.output.json

# Check Salt output for errors.
"${CHECK_SALT_OUTPUT_SCRIPT}" salt.output.json

