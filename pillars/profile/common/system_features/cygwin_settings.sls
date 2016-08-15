
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

        installation_directory: 'C:\cygwin64'

        # Checking existance of this file confirms existing installation.
        # NOTE: This is only used when `cygwin_installation_method`
        #       is NOT set to `bootstrap`.
        completion_file_indicator: 'C:\cygwin64\installed.txt'

        # See docs for CYGWIN environment variable:
        #   http://cygwin.com/cygwin-ug-net/using-cygwinenv.html
        CYGWIN_env_var_items_list:
            # Windows NTFS native symlink can be used in both inside and
            # outside of Cygwin:
            - winsymlinks:nativestrict

###############################################################################
# EOF
###############################################################################

