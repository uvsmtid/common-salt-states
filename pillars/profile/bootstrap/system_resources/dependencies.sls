
###############################################################################
#

system_resources:

    # This is required to install Salt on CentOS 5.5 (EPEL package is
    # discontinued).
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

    # PyYAML for 'uvsmtid/centos-7.0-minimal'.
    #   sudo yum install --downloadonly --downloaddir=. PyYAML
    PyYAML-3.10-11.el7.x86_64.rpms.tar:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/dependencies
        item_base_name: PyYAML-3.10-11.el7.x86_64.rpms.tar
        item_content_hash: md5=258e9621d85ffe2ff682dbd4b1a8083b

    # PyYAML for 'uvsmtid/centos-5.5-minimal'.
    # Note that EPEL repository should be enabled.
    #   sudo yum install yum-downloadonly
    #   sudo yum install --downloadonly --downloaddir=. PyYAML
    PyYAML-3.09-10.el5.x86_64.rpms.tar:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/dependencies
        item_base_name: PyYAML-3.09-10.el5.x86_64.rpms.tar
        item_content_hash: md5=10c7855bdaafae965725d697d99d6b6b

    # `unzip` package for CentOS 7.0 downloaded on minimal install OS:
    # sudo yum install --downloadonly --downloaddir=. unzip
    unzip-6.0-13.el7.x86_64.rpm:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/dependencies
        item_base_name: unzip-6.0-13.el7.x86_64.rpm
        item_content_hash: md5=abbb421ceca1a5c74e1b09609c97688e

    # `zip` package for CentOS 7.0 downloaded on minimal install OS:
    # sudo yum install --downloadonly --downloaddir=. zip
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

