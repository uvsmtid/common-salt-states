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

# Set proper Java version.
# TODO: Do not hardcode it - get from Salt pillar.
export JAVA_HOME='/usr/java/jdk1.7.0_71'
export PATH="${JAVA_HOME}/bin:${PATH}"

# Set Maven memory options.
# TODO: Do not hardcode it - get from Salt pillar.
export MAVEN_OPTS="-Xmx2048m -XX:MaxPermSize=512m"

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

# Get pillar.
if true
then

    sudo \
    "${RUNTIME_DIR}"/process_maven_data.py \
        c get_salt_pillar \
        --output_salt_pillar_yaml_file_path \
        "${RUNTIME_DIR}"/salt_pillar.yaml \

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

fi

# Get initial report data.
if true
then

    "${RUNTIME_DIR}"/process_maven_data.py \
        c get_initial_report_data \
        --input_salt_pillar_yaml_path \
        "${RUNTIME_DIR}"/salt_pillar.yaml \
        --input_all_pom_files_per_repo_yaml_path \
        "${RUNTIME_DIR}"/all_pom_files_per_repo.yaml \
        --output_pom_data_dir \
        "${RUNTIME_DIR}"/output_pom_data_dir \
        --output_initial_report_data_yaml_path \
        "${RUNTIME_DIR}"/initial_report_data.yaml \

fi

# Get verification report.
if true
then

    "${RUNTIME_DIR}"/process_maven_data.py \
        c get_verification_report \
        --input_initial_report_data_yaml_path \
        "${RUNTIME_DIR}"/initial_report_data.yaml \
        --output_verification_report_yaml_path \
        "${RUNTIME_DIR}"/verification_report.yaml \

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

fi

