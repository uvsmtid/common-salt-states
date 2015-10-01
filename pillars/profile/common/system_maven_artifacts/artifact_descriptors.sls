
###############################################################################
#

# YAML data describing currently known state of dependencies.
#
# This file is maintained manually. Script `check_maven_deps.py` is used
# to query all dependencies from Maven and verify against status of
# this file. If there are any discrepancies, the script fails.

system_maven_artifacts:

    artifact_descriptors:

        'GROUP_ID:ARTIFACT_ID': # TODO
            used: True
            source_type: modified-open
            repository_id: maven-demo
            item_path: pom.xml

            remarks: build success
            current_version: 0.0.0.0-SNAPSHOT

###############################################################################
# EOF
###############################################################################

