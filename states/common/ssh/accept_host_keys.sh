#!/bin/sh

# NOTE: This script only needs to accept host keys.
#       The attempt to connect is allowd to fail.

set -e
set -u
set -x

HOSTNAME="$1"
USERNAME="$2"

CURRENT_USERNAME="$(whoami)"
CURRENT_HOSTNAME="$(hostname)"

# Allow using default user (current local username or from `~/.ssh/config).
# If username is empty string, no '@' is used.
SEPARATOR=""
if [ -n "$USERNAME" ]
then
    SEPARATOR="@"
fi

# NOTE: We ignore any error code because this script is not supposed
#       to successfully log in and execute command. It is only required
#       to accept host keys (which it does).
# NOTE: We disable X11 forwarding by `-x` as it may slow down
#       execution considerably with the following error:
#           http://serverfault.com/q/422908
set +e
# -o "ConnectTimeout 5"
ssh \
    -x \
    -o "StrictHostKeyChecking no" \
    -o "PreferredAuthentications publickey" \
    "${USERNAME}${SEPARATOR}${HOSTNAME}" \
    "echo CONNECTION SUCCESSFUL"
set -e

# Check whether hostname is part of SSH "known_hosts" file:
grep "\<$HOSTNAME\>" ~/.ssh/known_hosts

