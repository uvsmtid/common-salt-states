#/bin/sh

# This is a helper script to generate required and existing order
# of items inside `observer.sls` file.

grep -r '^[^:[:space:]]*:' observer.sls        > existing.order.txt
grep -r '^[^:[:space:]]*:' observer.sls | sort > required.order.txt

echo "Compare order of entries in the files using one of the command below:" 1>&2
echo "  meld existing.order.txt required.order.txt" 1>&2
echo "  diff existing.order.txt required.order.txt" 1>&2

