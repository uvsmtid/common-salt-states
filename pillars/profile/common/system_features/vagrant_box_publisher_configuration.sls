
###############################################################################
#

system_features:

    vagrant_box_publisher_configuration:

        # NOTE: URL is not specified.
        #       Instead, access to the repositories is done via root path
        #       of hostname associated with `vagrant_box_publisher_role`, e.g.:
        #           http://vagrant-box-publisher-role-host/
        # NOTE: Due to big content size, this directory is
        #       actually a symlink to special storage location
        #       identified by `vagrant_box_publisher_role_content_dir`.
        vagrant_box_publisher_role_content_symlink: '/var/www/html/vagrant_box_publisher_role/content'

        # Default location for content of vagrant box publisher (on `vagrant_box_publisher_role`).
        vagrant_box_publisher_role_content_dir: '/home/vagrant_box_publisher_content'

###############################################################################
# EOF
###############################################################################

