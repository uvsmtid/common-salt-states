#!/bin/sh
#
# This is just a handy script to generate bootstrap package
# limited for current (local) target environment only.
#
# The script must be run:
# - from root of `common-salt-states.git`
# - with `sudo --preserve-env`

set -e
set -u
set -x

echo "WARNING: if not done so, this script must be run with \`sudo --preserve-env\` to preserve \`SALT_PROFILE_NAME\` environment variable" 1>&2

echo "SALT_PROFILE_NAME=${SALT_PROFILE_NAME}" 1>&2

CHECK_SALT_OUTPUT_SCRIPT="states/bootstrap/bootstrap.dir/modules/utils/check_salt_output.py"

if [ ! -f "${CHECK_SALT_OUTPUT_SCRIPT}" ]
then
    echo "Error: run from root of \`common-salt-states.git\` - script not found: ${CHECK_SALT_OUTPUT_SCRIPT}" 1>&2
fi

salt-call \
    --out json \
    state.sls bootstrap.generate_content \
    pillar="{ enable_bootstrap_target_envs: [ ${SALT_PROFILE_NAME} ] }" \
    test=False | tee salt.output.json

"${CHECK_SALT_OUTPUT_SCRIPT}" salt.output.json

