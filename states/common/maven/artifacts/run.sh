#!/bin/sh

# Get pillar.
sudo ./process_maven_artifacts.py c get_salt_pillar --output_salt_pillar_yaml_file_path salt_pillar.yaml

# Find pom files per repo.
./process_maven_artifacts.py c get_pom_files_per_repo --input_salt_pillar_yaml_path salt_pillar.yaml --output_pom_files_per_repo_yaml_path pom_files_per_repo.yaml

# TESTING ONLY
# Generate effective pom for specific file.
./process_maven_artifacts.py c get_effective_pom --input_original_pom_file_path ~/Works/observer.git/maven/maritime.git/preon/preon-el/pom.xml --output_effective_pom_file_path ~/Works/observer.git/maven/maritime.git/preon/preon-el/effective.pom.xml

# TESTING ONLY
# Get Maven dependencies for specific file.
./process_maven_artifacts.py c get_pom_dependencies --input_effective_pom_xml_path ~/Works/observer.git/maven/maritime.git/preon/preon-el/effective.pom.xml --output_pom_dependencies_yaml_path pom_dependencies.yaml

