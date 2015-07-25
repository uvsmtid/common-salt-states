
###############################################################################
#

system_resources:

    # TODO: Rely on official Salt YUM repository for RHEL5 to get it
    #       as part of dependencies for `salt-*` packages.
    # This is required to install Salt on CentOS 5.5
    # (EPEL package is discontinued).
    #
    # How to download (update)?
    # Downloaded on Vagrant virtual box 'uvsmtid/centos-5.5-minimal':
    #   sudo yum install yum-downloadonly
    #   sudo yum install --downloadonly --downloaddir=python26-distribute.rpms/ python26-distribute
    # TODO: CentOS 5.5 minimal DOES have `tar` (and gzip`/`gunzip`),
    #       but this is `zip`.
    python26-distribute_downloaded_rpms_with_dependencies_0.6.10-4.el5.x86_64:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/dependencies
        item_base_name: python26-distribute-0.6.10-4.el5.x86_64.rpms.zip
        item_content_hash: md5=8406a25dbd3bacdf87b52acaec096c8e

    ###########################################################################
    # PyYAML
    # The library is required to allow bootstrap script to load YAML data.

    # 'uvsmtid/centos-7.0-minimal'.
    #
    # How to download (update)?
    #   sudo yum install --downloadonly --downloaddir=PyYAML.rpms/ PyYAML
    PyYAML-3.10-11.el7.x86_64.rpms.tar:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/dependencies
        item_base_name: PyYAML-3.10-11.el7.x86_64.rpms.tar
        item_content_hash: md5=258e9621d85ffe2ff682dbd4b1a8083b

    # 'uvsmtid/centos-5.5-minimal'.
    #
    # How to download (update)?
    # Note that EPEL repository should be enabled.
    #   sudo yum install yum-downloadonly
    #   sudo yum install --downloadonly --downloaddir=PyYAML.rpms/ PyYAML
    PyYAML-3.09-10.el5.x86_64.rpms.tar:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/dependencies
        item_base_name: PyYAML-3.09-10.el5.x86_64.rpms.tar
        item_content_hash: md5=10c7855bdaafae965725d697d99d6b6b

    ###########################################################################
    # `zip`/`unzip`

    # TODO: Remove `zip` and use `tar` instead.
    # The `unzip` package for CentOS 7.0.
    #
    # How to download (update)?
    # Downloaded on minimal install OS:
    #   sudo yum install --downloadonly --downloaddir=unzip.rpms/ unzip
    unzip-6.0-13.el7.x86_64.rpm:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/dependencies
        item_base_name: unzip-6.0-13.el7.x86_64.rpm
        item_content_hash: md5=abbb421ceca1a5c74e1b09609c97688e

    # TODO: Remove `zip` and use `tar` instead.
    # The `zip` package for CentOS 7.0
    #
    # How to download (update)?
    # Downloaded on minimal install OS:
    #   sudo yum install --downloadonly --downloaddir=zip.rpms/ zip
    zip-3.0-10.el7.x86_64.rpm:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/dependencies
        item_base_name: zip-3.0-10.el7.x86_64.rpm
        item_content_hash: md5=4623f947ddc141f4d0f8e0bf4bf10529

###############################################################################
# EOF
###############################################################################

