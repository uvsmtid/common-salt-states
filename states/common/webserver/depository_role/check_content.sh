#!/bin/sh

# Example:
#  this_script.sh md5 /etc/hosts 1be4f7f644beb629d9031cdf69307345

set -x
set -e
set -u

# This script verifies checksum of the given file:
# $1 checksum type (command)
# $2 file path
# $3 checksum value

CHECKSUM_TYPE="$1"
FILE_PATH="$2"
EXPECTED_CHECKSUM_VALUE="$3"

# Get current value of the checksum.
CURR_CHECKSUM_VALUE="$("$CHECKSUM_TYPE" "$FILE_PATH" | cut -d' ' -f1)"

if [ "$CURR_CHECKSUM_VALUE" != "$EXPECTED_CHECKSUM_VALUE" ]
then
    echo "ERROR: \"$CHECKSUM_TYPE\" checksum mismatch for \"$FILE_PATH\": \"$EXPECTED_CHECKSUM_VALUE\" != \"$CURR_CHECKSUM_VALUE\"" 1>&2
    exit 1
else:
    echo "SUCCESS: \"$CHECKSUM_TYPE\" checksum is OK for \"$FILE_PATH\": \"$EXPECTED_CHECKSUM_VALUE\" == \"$CURR_CHECKSUM_VALUE\"" 1>&2
    exit 0
fi


