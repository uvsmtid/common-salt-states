#!/bin/sh
#
# This is just a handy script to check what jobs are currently running
# on any (or specific) minions.
#
# If nothing is running, script returns non-zero exit code.
#
# The script must be run:
# - with `sudo`

set -e
set -u
set -x
set -v

echo "WARNING: if not done so, this script must be run with \`sudo\`" 1>&2

# Temporary file to store salt output.
SALT_OUTPUT="$(mktemp)"

if [ $# -eq 0 ]
then
    MINIONS_SPEC="*"
else
    MINIONS_SPEC="$1"
fi

# NOTE: We are ready to wait for 10 min (600 sec) to get response.
salt \
    --timeout=600 \
    "${MINIONS_SPEC}" \
    --out json \
    saltutil.running \
| tee "${SALT_OUTPUT}"

# Check if there is anything running.
cat "${SALT_OUTPUT}" | grep '"jid":'

