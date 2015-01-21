#!/bin/sh

set -e
set -u
set -x

HOSTNAME="$1"

if ping -c 1 "$HOSTNAME"
then

    echo "$HOSTNAME: online" 1>&2
    exit 0

else

    echo "$HOSTNAME: offline" 1>&2
    exit 1

fi

