
###############################################################################
#

# YAML data describing currently known state of dependencies.
#
# This file is maintained manually. Script `check_maven_deps.py` is used
# to query all dependencies from Maven and verify against status of
# this file. If there are any discrepancies, the script fails.

system_maven_artifacts:

    artifact_descriptors:

        'com.spectsys.maven-demo:dependent_binary':
            used: True
            source_type: modified-open
            repository_id: maven-demo
            pom_relative_dir_path: dependent_binary
            current_version: 0.0.0.0-SNAPSHOT

        'com.spectsys.maven-demo:direct_library':
            used: True
            source_type: modified-open
            repository_id: maven-demo
            pom_relative_dir_path: direct_library
            current_version: 0.0.0.0-SNAPSHOT

        'com.spectsys.maven-demo:hello-world-maven-plugin':
            used: True
            source_type: modified-open
            repository_id: maven-demo
            pom_relative_dir_path: hello_world_maven_plugin
            current_version: 0.0.0.0-SNAPSHOT

        'com.spectsys.maven-demo:indirect_library':
            used: True
            source_type: modified-open
            repository_id: maven-demo
            pom_relative_dir_path: indirect_library
            current_version: 0.0.0.0-SNAPSHOT

        'com.spectsys.maven-demo:multi-module-build':
            used: True
            source_type: modified-open
            repository_id: maven-demo
            pom_relative_dir_path: ''
            current_version: 0.0.0.0-SNAPSHOT

        'junit:junit':
            used: True
            source_type: unmodified-open

            current_version:
                - '4.4'
                - '3.8.1'

        ':maven-antrun-plugin':
            used: True
            source_type: unmodified-open

            current_version:
                - '1.3'

        ':maven-assembly-plugin':
            used: True
            source_type: unmodified-open

            current_version:
                - '2.2-beta-5'

        ':maven-clean-plugin':
            used: True
            source_type: unmodified-open

            current_version:
                - '2.5'

        ':maven-compiler-plugin':
            used: True
            source_type: unmodified-open

            current_version:
                - '3.1'

        ':maven-dependency-plugin':
            used: True
            source_type: unmodified-open

            current_version:
                - '2.8'
                - '2.7'

        ':maven-deploy-plugin':
            used: True
            source_type: unmodified-open

            current_version:
                - '2.7'

        ':maven-install-plugin':
            used: True
            source_type: unmodified-open

            current_version:
                - '2.4'

        ':maven-jar-plugin':
            used: True
            source_type: unmodified-open

            current_version:
                - '2.4'

        ':maven-plugin-plugin':
            used: True
            source_type: unmodified-open

            current_version:
                - '3.2'

        ':maven-release-plugin':
            used: True
            source_type: unmodified-open

            current_version:
                - '2.3.2'
                - '2.5.1'

        ':maven-resources-plugin':
            used: True
            source_type: unmodified-open

            current_version:
                - '2.6'

        ':maven-site-plugin':
            used: True
            source_type: unmodified-open

            current_version:
                - '3.3'

        ':maven-surefire-plugin':
            used: True
            source_type: unmodified-open

            current_version:
                - '2.12.4'

        'org.apache.maven:maven-artifact':
            used: True
            source_type: unmodified-open

        'org.apache.maven:maven-plugin-api':
            used: True
            source_type: unmodified-open

            current_version:
                - '2.0'

        'org.apache.maven.plugins:maven-dependency-plugin':
            used: True
            source_type: unmodified-open

            current_version:
                - '2.7'

        'org.apache.maven.plugins:maven-project-info-reports-plugin':
            used: True
            source_type: unmodified-open

        'org.apache.maven.plugin-tools:maven-plugin-annotations':
            used: True
            source_type: unmodified-open

            current_version:
                - '3.4'

        'org.apache.maven.scm:maven-scm-provider-gitexe':
            used: True
            source_type: unmodified-open

            current_version:
                - '1.9.1'

        'org.codehaus.plexus:plexus-utils':
            used: True
            source_type: unmodified-open

###############################################################################
# EOF
###############################################################################

