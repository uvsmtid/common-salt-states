
###############################################################################
#

system_resources:

    # See description:
    #     https://github.com/uvsmtid/vagrant-boxes/tree/develop/centos-5.5-minimal
    centos-5.5-minimal-1.0.1.tar.gz:
        # TODO: Define this repository in resource repositories:
        #         pillars/profile/common/system_features/resource_repositories_configuration.sls
        resource_repository: vagrant_boxes
        bootstrap_use_cases: False
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: vagrant_boxes
        item_base_name: centos-5.5-minimal-1.0.1.tar.gz
        item_content_hash: sha256=7c747fbb11c978237e9962afc5bb6e9d2af1c77da0f0c1487ba17ba3d4983134

    # See description:
    #     https://github.com/uvsmtid/vagrant-boxes/tree/develop/centos-7.0-minimal
    centos-7.0-minimal-1.0.0.tar.gz:
        # TODO: Define this repository in resource repositories:
        #         pillars/profile/common/system_features/resource_repositories_configuration.sls
        resource_repository: vagrant_boxes
        bootstrap_use_cases: False
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: vagrant_boxes
        item_base_name: centos-7.0-minimal-1.0.0.tar.gz
        item_content_hash: sha256=296966177889c8674db9fa2edfbcfa8f303d7fca135d283ec0549f7b7af9ebc0

    # See description:
    #     https://github.com/uvsmtid/vagrant-boxes/tree/develop/centos-7.1-1503-gnome
    centos-7.1-1503-gnome-1.0.1-box.tar.gz:
        # TODO: Define this repository in resource repositories:
        #         pillars/profile/common/system_features/resource_repositories_configuration.sls
        resource_repository: vagrant_boxes
        bootstrap_use_cases: False
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: vagrant_boxes
        item_base_name: centos-7.1-1503-gnome-1.0.1-box.tar.gz
        item_content_hash: sha256=9ace6ec1ae8261e8a09432e851c6191be5a531292793801db8000033fa5de282

    # See description:
    #     https://github.com/uvsmtid/vagrant-boxes/tree/develop/windows-server-2012-R2-gui
    windows-server-2012-R2-gui-2.0.0-box.tar.gz:
        # TODO: Define this repository in resource repositories:
        #         pillars/profile/common/system_features/resource_repositories_configuration.sls
        resource_repository: vagrant_boxes
        bootstrap_use_cases: False
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: vagrant_boxes
        item_base_name: windows-server-2012-R2-gui-2.0.0-box.tar.gz
        item_content_hash: sha256=e497f4b70d22c8c8d4a5deceb73a58d8413b9e4519ad4b9bf274570e74514c3d

###############################################################################
# EOF
###############################################################################

