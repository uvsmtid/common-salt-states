
###############################################################################
#

system_features:

    # Disable installation of all packages.
    #
    # This is just a workaround initially developed for CentOS 5 and now
    # added as a configureable feature (which may be used similarily anywhere
    # else). But the only point it is here is just because of CentOS 5.5
    # (once it's not needed, it can be cleaned).
    #
    # The problem is that the following command
    # on CentOS 5.5 does not output anything:
    #   repoquery -a --pkgnarrow=installed
    # Salt uses this command to check and confirm installation
    # of specified packages and fails to see anything.
    # If CentOS is updated, there is no issue with this.
    allow_package_installation_through_yum:
        feature_enabled: True

###############################################################################
# EOF
###############################################################################

