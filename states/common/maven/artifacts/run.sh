#!/bin/sh

# Fail on non-zero exit.
set -e

# Fail on undefined var.
set -u

# Debug.
set -x

# Get pillar.
if true
then

    sudo ./process_maven_artifacts.py c get_salt_pillar \
        --output_salt_pillar_yaml_file_path salt_pillar.yaml \

fi

# Find pom files per repo.
if true
then

    ./process_maven_artifacts.py c get_all_pom_files_per_repo \
        --input_salt_pillar_yaml_path salt_pillar.yaml \
        --output_all_pom_files_per_repo_yaml_path all_pom_files_per_repo.yaml \

fi

# Get initial report data.
if true
then

    ./process_maven_artifacts.py c get_initial_report_data \
        --input_salt_pillar_yaml_path salt_pillar.yaml \
        --input_all_pom_files_per_repo_yaml_path all_pom_files_per_repo.yaml \
        --output_all_effective_poms_per_repo_dir all_effective_poms_per_repo_dir \
        --output_initial_report_data_yaml_path initial_report_data.yaml \

fi

# Get verification report.
if true
then

    ./process_maven_artifacts.py c get_verification_report \
        --input_initial_report_data_yaml_path initial_report_data.yaml \
        --output_verification_report_yaml_path verification_report.yaml \

fi

