
###############################################################################
#

system_features:

    # Confiugrations for some source version control tools.
    source_version_control_tools_config:

        # Personal svn configuration.
        #   TODO: it is not used anywere at the moment.
        svn:
            some_repo:
                url: 'TODO'
                username: TODO
                # TODO: Use `secret_id` from `system_secrets` for `password_value`.
                password: TODO

        # Personal git configuration.
        git:
            {% if False %} # Do not configure user system-wide by default.
            user_config:
                # Real name saved in git commits, for example:
                #   name: Barack Obama
                name: First Last
                # Email address saved in git commits, for example:
                #   email: barack.obama@example.com
                email: first.last@example.com
            {% endif %}

###############################################################################
# EOF
###############################################################################

