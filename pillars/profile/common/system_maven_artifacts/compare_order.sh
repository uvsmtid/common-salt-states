#/bin/sh

# This is a helper script to generate required and existing order
# of items inside `maven-demo.sls` file.

grep -r '^[^:[:space:]]*:' maven-demo.sls        > existing.order.txt
grep -r '^[^:[:space:]]*:' maven-demo.sls | sort > required.order.txt

echo "Compare order of entries in the files using one of the command below:" 1>&2
echo "  meld existing.order.txt required.order.txt" 1>&2
echo "  diff existing.order.txt required.order.txt" 1>&2

