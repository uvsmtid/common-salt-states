
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
        # TODO: Instead of specifying absolute path here, specify resource_repository_id
        #       which points to absolute path with content for this repository.
        vagrant_box_publisher_role_content_dir: '/home/vagrant_box_publisher_content'

        # NOTE: The structure of each value per key closely follows
        #       box descriptor example of which can be found in this manual:
        #           https://github.com/hollodotme/Helpers/blob/610323820a32222a756ad668e13b64e779bc73d9/Tutorials/vagrant/self-hosted-vagrant-boxes-with-versioning.md#53-change-the-box-catalog
        #       There are few omissions:
        #
        #       -   box `name`
        #
        #           Instead, key name is used when this data is rendered.
        #
        #       -   box/version/provider `url`
        #
        #           Instead, URL is generated based on other settings -
        #           role hostname, specified resource id, etc.
        #
        #       -   box/version/provider `checksum_type` and `checksum`
        #
        #           Instead, the values are directly derived from
        #           the specified `resource_id`.
        #
        # TODO: `resource_repository` of specified `resource_id` has to
        #       match with `resource_repository` id specified in
        #       (TODO: refactor) `vagrant_box_publisher_role_content_dir`.
        #
        # NOTE: Example of boxes to start with can be found in this repository:
        #           https://github.com/uvsmtid/vagrant-boxes
        vagrant_boxes:

            uvsmtid/centos-5.5-minimal:
                description: https://github.com/uvsmtid/vagrant-boxes/tree/develop/centos-5.5-minimal
                versions:
                -   version: 1.0.1
                    providers:
                    -   name: libvirt
                        resource_id: centos-5.5-minimal-1.0.1.tar.gz

            uvsmtid/centos-7.0-minimal:
                description: https://github.com/uvsmtid/vagrant-boxes/tree/develop/centos-7.0-minimal
                versions:
                -   version: 1.0.0
                    providers:
                    -   name: libvirt
                        resource_id: centos-7.0-minimal-1.0.0.tar.gz

            uvsmtid/centos-7.1-1503-gnome:
                description: https://github.com/uvsmtid/vagrant-boxes/tree/develop/centos-7.1-1503-gnome
                versions:
                -   version: 1.0.1
                    providers:
                    -   name: libvirt
                        resource_id: centos-7.1-1503-gnome-1.0.1-box.tar.gz

            uvsmtid/windows-server-2012-R2-gui:
                description: https://github.com/uvsmtid/vagrant-boxes/tree/develop/windows-server-2012-R2-gui
                versions:
                -   version: 1.0.0
                    providers:
                    -   name: libvirt
                        resource_id: windows-server-2012-R2-gui-1.0.0-box.tar.gz

###############################################################################
# EOF
###############################################################################

