#!/bin/sh
#
# This is just a handy script to show result of specific Salt job.

set -e
set -u

JID="$1"
FILE="test.results.yaml"

salt-run jobs.lookup_jid "$JID" | tee "$FILE"

echo "See: $FILE" 1>&2

