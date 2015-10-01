
###############################################################################
#

# Some of the sources may contain pom files as resource (not to be
# considered during the build). However, validation job searches for all
# pom files and triggers failure if there is any pom file which does not
# have corresponding artifact defined in:
#   system_maven_artifacts:artifact_descriptors
# This file lists Maven pom file exceptions which have to be ignored.

system_maven_artifacts:

    pom_file_exceptions:

        maven-demo:
            # No exceptions.
            - this/pom/file/does/not/exists/pom.xml

###############################################################################
# EOF
###############################################################################

