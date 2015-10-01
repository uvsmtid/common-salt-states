#!/bin/sh

# Get pillar.
sudo ./process_maven_artifacts.py c get_salt_pillar --output_salt_pillar_yaml_file_path salt_pillar.yaml

# Find pom files per repo.
./process_maven_artifacts.py c get_pom_files_per_repo --input_salt_pillar_yaml_path salt_pillar.yaml --output_pom_files_per_repo_yaml_path pom_files_per_repo.yaml

