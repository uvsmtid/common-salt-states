
###############################################################################
#

system_features:

    cygwin_settings:

        # There is a `common.cygwin.package` state which can install
        # Cygwin on clean OS using package saved under
        # `cygwin_package_64_bit_windows` resource id.
        # However, the latest approach is to install Cygwin immediately
        # during bootstrap (bootstrap pacakge installs it right away).
        cygwin_installation_method: bootstrap

###############################################################################
# EOF
###############################################################################

