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

# Get directory the script is in.
RUNTIME_DIR="$( realpath "$( pwd )/$( dirname "${0}" )" )"

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
        --output_all_effective_poms_per_repo_dir \
        "${RUNTIME_DIR}"/all_effective_poms_per_repo_dir \
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

