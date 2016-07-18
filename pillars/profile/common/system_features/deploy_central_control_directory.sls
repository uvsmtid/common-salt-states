
###############################################################################
#

system_features:

    # Deploy central control directory with descriptor.
    #
    # The actual deployment only works if `depository_role` (where the directory is
    # deployed) is under Salt control (Salt minion).
    #
    deploy_central_control_directory:

        # NOTE: Even if the feature is disabled (to disable actual deployment),
        #       the configuration is still used in other states.
        #       For example, Jenkins job configuration sets control URL
        #       based on these fields.

        # TODO: This is an obsolete approach with control scripts in special
        #       external repository. Disable until a better solution found.
        feature_enabled: False

        # Path to central configuration relative to source code root (see
        # `source_symlinks` in `source_symlinks_configuration` feature):
        control_dir_src_path: 'conf'

        # File system path on the webserver where the configuration is
        # deployed (see `common.webserver.depository_role` state):
        control_dir_fs_path: '/var/www/html/depository_role/content/control/conf'

        # Control scripts URI prefix (similar to `URI_prefix` for registered
        # content resources).
        #
        # The reason why it may be needed is that content resources can
        # actually be distributed by Salt states (using `salt://` schema for
        # URI), but (external) control scripts require standard/known URI
        # schemes (i.e. `http://`, `file://`, ...) to be functional.
        URI_prefix: 'http://depository-role-host'

        # URL part leading to control directory on the web server (to be
        # combined with `URI_prefix`):
        control_dir_url_path: 'control/conf'

###############################################################################
# EOF
###############################################################################

