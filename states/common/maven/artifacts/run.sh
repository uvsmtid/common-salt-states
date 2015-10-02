#!/bin/sh

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

# TESTING ONLY
# Generate effective pom for specific file.
if false
then

    ./process_maven_artifacts.py c get_single_effective_pom \
        --input_original_pom_file_path ~/Works/observer.git/maven/maritime.git/preon/preon-el/pom.xml \
        --output_single_effective_pom_file_path ~/Works/observer.git/maven/maritime.git/preon/preon-el/effective.pom.xml \

fi

# TESTING ONLY
# Get Maven dependencies for specific file.
if false
then

    ./process_maven_artifacts.py c get_single_pom_dependencies \
        --input_single_effective_pom_xml_path ~/Works/observer.git/maven/maritime.git/preon/preon-el/effective.pom.xml \
        --output_single_pom_dependencies_yaml_path single_pom_dependencies.yaml \

fi

# TESTING ONLY
# Generate all effective pom files per repo.
if false
then

    ./process_maven_artifacts.py c get_all_effective_poms_per_repo \
        --input_all_pom_files_per_repo_yaml_path all_pom_files_per_repo.yaml \
        --output_all_effective_poms_per_repo_yaml_path all_effective_poms_per_repo.yaml \
        --output_all_effective_poms_per_repo_dir all_effective_poms_per_repo_dir \

fi

# Get verification report.
if true
then

    ./process_maven_artifacts.py c get_verification_report_pom_files_with_artifact_descriptors \
        --input_salt_pillar_yaml_path salt_pillar.yaml \
        --input_all_pom_files_per_repo_yaml_path all_pom_files_per_repo.yaml \
        --output_all_effective_poms_per_repo_dir all_effective_poms_per_repo_dir \
        --output_verification_report_pom_files_with_artifact_descriptors_yaml_path verification_report_pom_files_with_artifact_descriptors.yaml\

fi

