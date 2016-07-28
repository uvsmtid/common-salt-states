
###############################################################################
#

system_resources:

    # This cygwin package was created by using `cygwin-offline`:
    #   https://github.com/uvsmtid/cygwin-offline
    # NOTE: It is used specifically in bootstrap package to install Salt.
    bootstrap_cygwin_package_64_bit_windows:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/cygwin
        item_base_name: cygwin-offline.git.v0.0.0-1-gdbdcd25.zip
        item_content_hash: 948c27875cd400b620623912f5d29cbc

###############################################################################
# EOF
###############################################################################

