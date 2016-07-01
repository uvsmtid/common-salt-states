#!/bin/sh

# This script verifies artifacts descriptors in Salt pillar with actual
# Maven configuration in `pom.xml` files.
# This shell script is just a wrapper around execution steps
# of (Python) script which performs all the processing.

# Fail on non-zero exit.
set -e

# Fail on undefined var.
set -u

# Debug.
set -x

# Return last non-zero exit code from piped command.
# See: http://unix.stackexchange.com/a/14282/23886
set -o pipefail

# Set proper Java version.
# TODO: Do not hardcode it - get from Salt pillar.
export JAVA_HOME='/usr/java/jdk1.7.0_71'
export PATH="${JAVA_HOME}/bin:${PATH}"

# Set Maven memory options.
# TODO: Do not hardcode it - get from Salt pillar.
export MAVEN_OPTS="-Xmx2048m -XX:MaxPermSize=512m"

# OBS-2336: Put required Maven version in front of the `PATH`.
# It is supposed to be deployed by Salt.
if [ -d "/opt/maven/apache-maven-3.2.5/bin" ]
then
    export PATH="/opt/maven/apache-maven-3.2.5/bin:$PATH"
    export M2_HOME="/opt/maven/apache-maven-3.2.5"
fi

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

OUT_FILE="${RUNTIME_DIR}/verify.sh.out"
: > "${OUT_FILE}"

# If `clean` parameter is specified, it start from scratch
# (removing previous files with data).
if [ "clean" == "${1:-}" ]
then

    rm -rf \
        "${RUNTIME_DIR}"/salt_pillar.yaml \
        "${RUNTIME_DIR}"/all_pom_files_per_repo.yaml \
        "${RUNTIME_DIR}"/output_pom_data_dir \
        "${RUNTIME_DIR}"/incremental_report.yaml \
        2>&1 | tee -a "${OUT_FILE}" \

fi

# Get pillar.
if true
then

    # NOTE: If pillar has syntax issues, Salt won't report failed exit status.
    #       Detect errors by removing original file and test existance
    #       of the new one.
    rm -f "${RUNTIME_DIR}"/salt_pillar.yaml

    sudo \
    --preserve-env \
    "${RUNTIME_DIR}"/process_maven_data.py \
        c get_salt_pillar \
        --output_salt_pillar_yaml_file_path \
        "${RUNTIME_DIR}"/salt_pillar.yaml \
        2>&1 | tee -a "${OUT_FILE}" \

    # NOTE: Test if Salt was able to generate the file.
    test -f "${RUNTIME_DIR}"/salt_pillar.yaml

fi

# Find pom files per repo.
if true
then

    "${RUNTIME_DIR}"/process_maven_data.py \
        c get_all_pom_files_per_repo \
        --input_salt_pillar_yaml_path \
        "${RUNTIME_DIR}"/salt_pillar.yaml \
        --output_all_pom_files_per_repo_yaml_path \
        "${RUNTIME_DIR}"/all_pom_files_per_repo.yaml \
        2>&1 | tee -a "${OUT_FILE}" \

fi

# Increment report.
if true
then

    "${RUNTIME_DIR}"/process_maven_data.py \
        c get_incremental_report \
        --input_salt_pillar_yaml_path \
        "${RUNTIME_DIR}"/salt_pillar.yaml \
        --input_all_pom_files_per_repo_yaml_path \
        "${RUNTIME_DIR}"/all_pom_files_per_repo.yaml \
        --output_pom_data_dir \
        "${RUNTIME_DIR}"/output_pom_data_dir \
        --input_incremental_report_yaml_path \
        "${RUNTIME_DIR}"/incremental_report.yaml \
        --output_incremental_report_yaml_path \
        "${RUNTIME_DIR}"/incremental_report.yaml \
        2>&1 | tee -a "${OUT_FILE}" \

fi

