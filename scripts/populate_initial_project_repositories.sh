#!/bin/sh
###############################################################################
# This interactive script generates initial content for
# `project_name-salt-states.git` and `project_name-salt-pillars.git`
# Git repositories with required layout.
#
# The required content is copied from `common-salt-states.git` into
# the respective Git repo.
#
# TODO: Add reference to documentation.

# Fail on error and on undefined variable.
set -e
set -u

REPO_CASE="no"
echo "There are two cases:"
echo "*   \"states\"  : create initial states for custom \`project_name\` with \"defaults\" pillars"
echo "*   \"pillars\" : create initial pillars for specific  \`profile_name\` with \"overrides\" pillars"
echo "Type case name exactly to proceed."
read REPO_CASE
if [ "${REPO_CASE}" == "states" ]
then
    echo "User typed \"${REPO_CASE}\". Proceeding with \"states\"..." 1>&2
elif [ "${REPO_CASE}" == "pillars" ]
then
    echo "User typed \"${REPO_CASE}\". Proceeding with \"pillars\"..." 1>&2
else
    echo "User typed \"${REPO_CASE}\". No such case. Exiting..." 1>&2
    exit 1
fi

# Get repo path.
if [ -z "${1:-}" ]
then
    echo "Enter absolute path to project ${REPO_CASE} repository:"
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

# Get project_name.
if [ -z "${2:-}" ]
then
    echo "Enter name of the project:"
    read PROJECT_NAME
    # TODO: Sanitize input.
else
    PROJECT_NAME="${2}"
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
# This default layout is required to link
# "defaults" (in case of `states` repository) and
# "overrides" (in case of `pillars` repository).
for ITEM_PATH in \
    "pillars" \
    "pillars/profile" \
    "pillars/profile/${PROJECT_NAME}" \

do
    echo "ADD: dir  : ${ITEM_PATH}" 1>&2
    mkdir -p "${DST_REPO_DIR}/${ITEM_PATH}"

    if [ "${REPO_CASE}" == "pillars" ]
    then
        # Skip creation of subdirectory named after `project_name`.
        # Normally, if required, all overriding files with their
        # parent directories are created manually.
        if [ "${ITEM_PATH}" == "pillars/profile/${PROJECT_NAME}" ]
        then
            continue
        fi
    fi

done

# Fill in initial pillars (`*.sls`) files.
for ITEM_PATH in \
    pillars/profile/properties.yaml \
    pillars/profile/overrides.sls \
    .gitignore \

do

    if [ "${REPO_CASE}" == "states" ]
    then
        # Skip `overrides.sls` which is overriden in "pillars" anyway.
        # And even if it is not overriden, deaults are present in "commons".

        # File `properties.yaml` is not skipped as it may provide useful
        # `project_name`-specific template for every new `profile_name`.

        if [ "${ITEM_PATH}" == "pillars/profile/overrides.sls" ]
        then
            continue
        fi

    fi

    ITEM_DIRNAME="$(dirname "${ITEM_PATH}")"
    echo "ADD: file : ${ITEM_PATH}" 1>&2
    cp -pr "${RUNTIME_DIR}/${COMMON_SALT_STATES_REPO_ROOT_DIR}/${ITEM_PATH}" "${DST_REPO_DIR}/${ITEM_DIRNAME}"

done

# Add template pillars files.
# They are only needed for "states" case.
if [ "${REPO_CASE}" == "states" ]
then

    for ITEM_PATH in \
        pillars/profile/project_name/init.sls \
        pillars/profile/project_name/main.sls \

    do
        ITEM_BASENAME="$(basename "${ITEM_PATH}")"
        DESTINATION_DIR="pillars/profile/${PROJECT_NAME}"
        echo "ADD: file : ${ITEM_PATH} => ${DESTINATION_DIR}/${ITEM_BASENAME}" 1>&2
        mkdir -p "$(dirname "${DST_REPO_DIR}/${DESTINATION_DIR}/${ITEM_BASENAME}")"
        cp -pr "${RUNTIME_DIR}/${COMMON_SALT_STATES_REPO_ROOT_DIR}/${ITEM_PATH}" "${DST_REPO_DIR}/${DESTINATION_DIR}/${ITEM_BASENAME}"
    done

fi

# Add initial states.
# They are only needed for "states" case.
if [ "${REPO_CASE}" == "states" ]
then

    for ITEM_PATH in \
        states/common/main.sls \

    do
        ITEM_BASENAME="$(basename "${ITEM_PATH}")"
        DESTINATION_DIR="states/${PROJECT_NAME}"
        echo "ADD: file : ${ITEM_PATH} => ${DESTINATION_DIR}/${ITEM_BASENAME}" 1>&2
        mkdir -p "$(dirname "${DST_REPO_DIR}/${DESTINATION_DIR}/${ITEM_BASENAME}")"
        cp -pr "${RUNTIME_DIR}/${COMMON_SALT_STATES_REPO_ROOT_DIR}/${ITEM_PATH}" "${DST_REPO_DIR}/${DESTINATION_DIR}/${ITEM_BASENAME}"
    done

fi

# Print message for user.
echo ""
echo "########################################################################"
echo ""
echo "The initial content for \`${REPO_CASE}\` repository has been generated."
echo ""
echo "*   Review and commit initial files:"
echo "        cd \"${DST_REPO_DIR}\""
echo "        git add --all"
echo "        git commit"
echo ""
if [ "${REPO_CASE}" == "pillars" ]
then
echo "*   Customize \`properties.yaml\` and \`overrides.sls\` files:"
echo "        vim \"${DST_REPO_DIR}/pillars/profile/properties.yaml\""
echo "        vim \"${DST_REPO_DIR}/pillars/profile/overrides.sls\""
echo "    In particular, specify absolute path to required repositories."
echo ""
echo "*   Configure Salt master:"
echo "        scripts/configure_salt.py \"${DST_REPO_DIR}/pillars/profile/properties.yaml\""
echo ""
elif [ "${REPO_CASE}" == "states" ]
then
echo "*   Customize \`properties.yaml\` files:"
echo "        vim \"${DST_REPO_DIR}/pillars/profile/properties.yaml\""
echo "    While this file is overriden in \`overrides\` pillars"
echo "    (in \`pillars\` repository), it may still serve as initial template"
echo "    for new \`profile_name\`s of entire \"${PROJECT_NAME}\" project."
echo ""
echo "*   Customize \`main.sls\` file which call various host role states:"
echo "        vim \"${DST_REPO_DIR}/${PROJECT_NAME}/main.sls\""
echo ""
fi

###############################################################################
# EOF
###############################################################################

