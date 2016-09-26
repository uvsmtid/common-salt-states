#!/bin/sh
###############################################################################
#
# This is a handy script to dump pillars for specified profile into a file.
# The pillars are saved in json format (can be loaded by YAML as its subset).
#
# There is only one optional argument:
#   - profile_name to save pillars for
#
###############################################################################

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

# Retrieve absolute path to repo with `bootstrap_target_profile_pillars`:
BOOTSTRAP_TARGET_PROFILE_REPO="$(sudo salt-call --out txt pillar.get properties:repo_path_bootstrap_target_profile_pillars | cut -d' ' -f2)"

# Checkout required branch within repository.
cd "${BOOTSTRAP_TARGET_PROFILE_REPO}"
git checkout "${BOOTSTRAP_TARGET_PROFILE}"
cd -

# Get pillars from Salt.
sudo salt-call \
    --out json \
    pillar.items  \
    | tee salt.pillars.json

###############################################################################
# EOF
###############################################################################

