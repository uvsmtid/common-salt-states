
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

system_maven_artifacts:

    # This key specifies location of `pom.xml` file which
    # is used as root in Maven multi-module reactor build.
    # In other words, reactor build of this `pom.xml` file
    # is supposed to build everything.
    maven_reactor_root_pom:

        repository_id: maven-demo
        pom_relative_dir_path: ''

###############################################################################
# EOF
###############################################################################

