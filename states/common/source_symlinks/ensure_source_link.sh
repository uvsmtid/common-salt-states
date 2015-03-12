#!/bin/sh

set -e
set -x
set -u

TARGET_BASE_DIR_ABS_PATH="$1"
LINK_ABS_PATH="$2"
TARGET_REL_PATH="$3"

# NOTE: Paths are simply concatenated
TARGET_ABS_PATH="$TARGET_BASE_DIR_ABS_PATH/$TARGET_REL_PATH"

if [ -L "$LINK_ABS_PATH" ]
then
    readlink "$LINK_ABS_PATH" | grep -F "$TARGET_BASE_DIR_ABS_PATH"
else
    if [ -e "$LINK_ABS_PATH" ]
    then
        echo "error: \"$LINK_ABS_PATH\" already exists and not a symlink" 1>&2
        exit 1
    else
        # Take dirname and makesure it exists.
        LINK_DIRNAME_ABS_PATH="$(dirname "$LINK_ABS_PATH")"
        mkdir -p "$LINK_DIRNAME_ABS_PATH"

        # Create link itself.
        # NOTE: Option `-n` prevents mess when link points to existing link.
        ln -sn "$TARGET_ABS_PATH" "$LINK_ABS_PATH"
    fi
fi

