#/bin/sh

# This is a helper script to generate required and existing order
# of items inside `artifact_descriptors.sls` file.

# The search is done for strings (keys) containing GROUP_ID:ARTIFACT_ID.
grep -r '^[^:][^:]*:[^:][^:]*:[[:space:]]*$' artifact_descriptors.sls        > existing.order.txt
grep -r '^[^:][^:]*:[^:][^:]*:[[:space:]]*$' artifact_descriptors.sls | sort > required.order.txt

echo "Compare order of entries in the files using one of the command below:" 1>&2
echo "  meld existing.order.txt required.order.txt" 1>&2
echo "  diff existing.order.txt required.order.txt" 1>&2

