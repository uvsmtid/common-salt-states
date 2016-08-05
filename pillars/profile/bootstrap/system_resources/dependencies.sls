
###############################################################################
#

system_resources:

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

    # DISABLED: Both LibYAML and PyYAML are pre-installed with Cygwin.
    {% if False %} # libyaml

    # 'uvsmtid/windows-server-2012-R2-gui`.
    # Downloaded from:
    #   http://pyyaml.org/wiki/LibYAML
    # Direct link:
    #   http://pyyaml.org/download/libyaml/yaml-0.1.5.tar.gz
    cygwin_bootstrap_LibYAML:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/dependencies
        item_base_name: yaml-0.1.5.tar.gz
        item_content_hash: md5=24f6093c1e840ca5df2eb09291a1dbf1
        # Relative path to subdirectory to unpacked content.
        content_root_subdir_path_cygwin: yaml-0.1.5

    # 'uvsmtid/windows-server-2012-R2-gui'.
    # Downloaded from:
    #   http://pyyaml.org/wiki/PyYAML
    # Direct link:
    #   http://pyyaml.org/download/pyyaml/PyYAML-3.11.tar.gz
    cygwin_bootstrap_PyYAML:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/dependencies
        item_base_name: PyYAML-3.11.tar.gz
        item_content_hash: md5=f50e08ef0fe55178479d3a618efe21db
        # Relative path to subdirectory to unpacked content.
        content_root_subdir_path_cygwin: PyYAML-3.11

    {% endif %} # libyaml

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

