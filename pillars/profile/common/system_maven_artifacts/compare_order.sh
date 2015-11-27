#/bin/sh

set -e
set -u

# This is a helper script to generate required and existing order
# of items inside `artifact_descriptors.sls` file.

# Note that duplicates also cause error code in addition to unordered ones.
# The search is done for strings (keys) containing GROUP_ID:ARTIFACT_ID.
grep -r '^[^:][^:]*:[^:][^:]*:[[:space:]]*$' artifact_descriptors.sls           > existing.order.txt
grep -r '^[^:][^:]*:[^:][^:]*:[[:space:]]*$' artifact_descriptors.sls | sort -u > required.order.txt

set -e
diff existing.order.txt required.order.txt 1>&2
RET_VAL="$?"
set +e

if [ "${RET_VAL}" != "0" ]
then
    echo "WARNING: The list of artifacts is not ordered or has duplicates." 1>&2
    echo "         The order is required to simplify merging of concurrent changes." 1>&2
    echo "Compare order of entries in the files using one of the command below:" 1>&2
    echo "  meld existing.order.txt required.order.txt" 1>&2
    echo "  diff existing.order.txt required.order.txt" 1>&2
    exit "${RET_VAL}"
else
    echo "INFO: Files existing.order.txt required.order.txt are the same." 1>&2
fi

