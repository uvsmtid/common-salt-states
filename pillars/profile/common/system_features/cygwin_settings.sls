
###############################################################################
#

system_features:

    cygwin_settings:

        # There is a `common.cygwin.package` state which can install
        # Cygwin on clean OS using package saved under
        # `cygwin_package_64_bit_windows` resource id.
        # However, the latest approach is to install Cygwin immediately
        # during bootstrap (bootstrap pacakge installs it right away).
        #
        # If Cygwin is completely absent on the target system
        # (by any installation method), set it to None (~).
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

        # There are two methods to setup SSH:
        #   - user
        #       This method sets SSH server as application auto-started
        #       as user logs in.
        #   - service
        #       This is the standard method to set up Windows service.
        cygwin_ssh_service_setup_method: service

###############################################################################
# EOF
###############################################################################

