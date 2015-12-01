#!/bin/sh
###############################################################################
# This script creates initial Git repo with layout for "overrides" pillars.
# TODO: Add reference to documentation.

# Fail on error and on undefined variable.
set -e
set -u

# Destination directory.
DST_REPO_DIR="${1}"

# Hardcoded relative path to `common-salt-states` repository root.
COMMON_SALT_STATES_REPO_ROOT_DIR='..'

# Get directory the script is in.
SCRIPT_DIR="$( dirname "${0}" )"
if [ "${SCRIPT_DIR:0:1}" == '/' ]
then
    # In case of absolute path, just use script dir.
    RUNTIME_DIR="$( realpath "${SCRIPT_DIR}" )"
else
    # In case of relative path, append current workind dir.
    RUNTIME_DIR="$( realpath "$( pwd )/${SCRIPT_DIR}" )"
fi

# Destination path should not exist.
if [ -e "${DST_REPO_DIR}" ]
then
    echo "ERROR: Destination directory exists: ${DST_REPO_DIR}" 1>&2
    exit 1
fi

# Enforce `*.git` naming convention.
if echo "${DST_REPO_DIR}" | grep -v '[.]git$'
then
    echo "ERROR: Destination directory should have \`.git\` extension by convention: ${DST_REPO_DIR}" 1>&2
    exit 1
else
    git init "${DST_REPO_DIR}"
fi

# Create directory layout.
for ITEM_DIR in \
    pillars \
    pillars/profile \
    pillars/bootstrap \
    pillars/bootstrap/profiles \

do
    mkdir -p "${DST_REPO_DIR}/${ITEM_DIR}"
done

# Fill in initial `*.sls` files.
for ITEM_PATH in \
    pillars/profile/properties.yaml \
    pillars/bootstrap/profiles/.gitignore \
    pillars/profile/overrides.sls \
    .gitignore \

do
    ITEM_DIRNAME="$(dirname "${ITEM_PATH}")"
    cp -pr "${RUNTIME_DIR}/${COMMON_SALT_STATES_REPO_ROOT_DIR}/${ITEM_PATH}" "${DST_REPO_DIR}/${ITEM_DIRNAME}"
done

# Print message for user.
echo ""
echo "########################################################################"
echo ""
echo "The initial \`pillars\` repository for \`overrides\` created."
echo ""
echo "*   Review and commit initial files:"
echo "        cd \"${DST_REPO_DIR}\""
echo "        git add --all"
echo "        git commit"
echo ""
echo "*   Customize \`properties.yaml\` and \`overrides.sls\` files:"
echo "        vim \"${DST_REPO_DIR}/pillars/profile/properties.yaml\""
echo "        vim \"${DST_REPO_DIR}/pillars/profile/overrides.sls\""
echo "    In particular, specify absolute path to required repositories."
echo ""
echo "*   Configure Salt master:"
echo "        scripts/configure_salt.py \"${DST_REPO_DIR}/pillars/profile/properties.yaml\""
echo ""

###############################################################################
# EOF
###############################################################################

