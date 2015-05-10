###############################################################################
#

system_features:

    # The following feature simply adds required users to sudo file.
    # For example:
    #   username ALL=(ALL) ALL
    configure_sudo_for_specified_users:

        feature_enabled: True

        # Location of the `sudo` stub utility to be used in Cygwin (relative
        # to Salt `file_roots`):
        path_to_cygwin_sudo: 'source_roots/common-salt-states/states/common/sudo/sudo_windows_script'

        include_primary_users:
            enabled: True
            disable_tty_requirement: True
            disable_password: True

###############################################################################
# EOF
###############################################################################

