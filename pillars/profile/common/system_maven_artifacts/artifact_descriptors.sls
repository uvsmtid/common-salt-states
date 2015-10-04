
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
            pom_relative_path: dependent_binary/pom.xml
            current_version: 0.0.0.0-SNAPSHOT

        'com.spectsys.maven-demo:direct_library':
            used: True
            source_type: modified-open
            repository_id: maven-demo
            pom_relative_path: direct_library/pom.xml
            current_version: 0.0.0.0-SNAPSHOT

        'com.spectsys.maven-demo:hello-world-maven-plugin':
            used: True
            source_type: modified-open
            repository_id: maven-demo
            pom_relative_path: hello_world_maven_plugin/pom.xml
            current_version: 0.0.0.0-SNAPSHOT

        'com.spectsys.maven-demo:indirect_library':
            used: True
            source_type: modified-open
            repository_id: maven-demo
            pom_relative_path: indirect_library/pom.xml
            current_version: 0.0.0.0-SNAPSHOT

        'com.spectsys.maven-demo:multi-module-build':
            used: True
            source_type: modified-open
            repository_id: maven-demo
            pom_relative_path: pom.xml
            current_version: 0.0.0.0-SNAPSHOT

        'junit:junit':
            used: True
            source_type: unmodified-open

        ':maven-antrun-plugin':
            used: True
            source_type: unmodified-open

        ':maven-assembly-plugin':
            used: True
            source_type: unmodified-open

        ':maven-clean-plugin':
            used: True
            source_type: unmodified-open

        ':maven-compiler-plugin':
            used: True
            source_type: unmodified-open

        ':maven-dependency-plugin':
            used: True
            source_type: unmodified-open

        ':maven-deploy-plugin':
            used: True
            source_type: unmodified-open

        ':maven-install-plugin':
            used: True
            source_type: unmodified-open

        ':maven-jar-plugin':
            used: True
            source_type: unmodified-open

        ':maven-plugin-plugin':
            used: True
            source_type: unmodified-open

        ':maven-release-plugin':
            used: True
            source_type: unmodified-open

        ':maven-resources-plugin':
            used: True
            source_type: unmodified-open

        ':maven-site-plugin':
            used: True
            source_type: unmodified-open

        ':maven-surefire-plugin':
            used: True
            source_type: unmodified-open

        'org.apache.maven:maven-artifact':
            used: True
            source_type: unmodified-open

        'org.apache.maven:maven-plugin-api':
            used: True
            source_type: unmodified-open

        'org.apache.maven.plugins:maven-project-info-reports-plugin':
            used: True
            source_type: unmodified-open

        'org.apache.maven.plugin-tools:maven-plugin-annotations':
            used: True
            source_type: unmodified-open

        'org.apache.maven.scm:maven-scm-provider-gitexe':
            used: True
            source_type: unmodified-open

        'org.codehaus.plexus:plexus-utils':
            used: True
            source_type: unmodified-open

###############################################################################
# EOF
###############################################################################

