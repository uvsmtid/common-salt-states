#!/bin/sh
###############################################################################
# This interactive script generates initial content
# with required layout for Git repo with "overrides" or "defaults" pillars.
#
# The required content is copied from `common-salt-states.git` into
# the actual `project_name-salt-pillars.git` Git repo.
#
# TODO: Add reference to documentation.

# Fail on error and on undefined variable.
set -e
set -u

# Get pillars repo path.
if [ -z "${1:-}" ]
then
    echo "Enter absolute path to pillars repository:"
    read DST_REPO_DIR
    # TODO: Sanitize input.
else
    DST_REPO_DIR="${1}"
fi

# Make sure path is absolute.
if [ "${DST_REPO_DIR:0:1}" != "/" ]
then
    echo "ERROR: Path is not absolute: ${DST_REPO_DIR}" 1>&2
    exit 1
fi

# Make sure target directory exists.
if [ ! -d "${DST_REPO_DIR}" ]
then
    echo "ERROR: Directory does not exists: ${DST_REPO_DIR}"
    exit 1
fi

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

USER_ANSWER="no"
echo "Some files in the destination directory may be overwritten."
echo "Type exactly \"YEAH!\" to proceed."
read USER_ANSWER
if [ "${USER_ANSWER}" != "YEAH!" ]
then
    echo "User typed \"${USER_ANSWER}\". Exiting..." 1>&2
    exit 1
else
    echo "User typed \"${USER_ANSWER}\". Proceeding..." 1>&2
fi

echo "" 1>&2
echo "Copying necessary template files:" 1>&2

# Create directory layout.
for ITEM_PATH in \
    pillars \
    pillars/profile \
    pillars/bootstrap \
    pillars/bootstrap/profiles \

do
    echo "ADD: dir  : ${ITEM_PATH}" 1>&2
    mkdir -p "${DST_REPO_DIR}/${ITEM_PATH}"
done

# Fill in initial `*.sls` files.
for ITEM_PATH in \
    pillars/profile/properties.yaml \
    pillars/bootstrap/profiles/.gitignore \
    pillars/profile/overrides.sls \
    .gitignore \

do
    ITEM_DIRNAME="$(dirname "${ITEM_PATH}")"
    echo "ADD: file : ${ITEM_PATH}" 1>&2
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

