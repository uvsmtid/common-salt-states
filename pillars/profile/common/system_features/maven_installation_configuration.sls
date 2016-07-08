
###############################################################################
#

system_features:

    maven_installation_configuration:

        # NOTE: Use custom Maven installation instead of standard one.
        {% if False %}
        maven_home_dir: '/usr/share/maven'
        {% else %}
        maven_home_dir: '/opt/maven/apache-maven-3.2.5'
        {% endif %}


        # Specify list of (additionally) activated profiles.
        # These profiles will be added to `<activeProfiles>`
        # system-wide (per user) `settings.xml` configuration file.
        activate_profiles:
            []

###############################################################################
# EOF
###############################################################################

