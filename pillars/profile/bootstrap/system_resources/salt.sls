
###############################################################################
#

system_resources:

    ###########################################################################
    # Salt for Fedora 21 = platform `fc21`
    # TODO: Currently, it is reused for `fc22`, `fc23`, `fc24`, ..., `fc25`.
    #       add separate packages per platform type.

    # TODO: There is own vagrant image: 'uvsmtid/fedora-21-server-minimal'.
    # Downloaded on Vagrant virtual box 'hansode/fedora-21-server-x86_64':
    #   sudo yum install --downloadonly --downloaddir=salt-minion.rpms/ salt-minion
    # There are neither `zip` nor `tar` command on minimal F21.
    salt-minion_downloaded_rpms_with_dependencies_2014.7.1-1.fc21.x86_64:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/salt
        item_base_name: salt-minion-2014.7.1-1.fc21.x86_64.rpms.tar
        item_content_hash: md5=6bb9952118afc6c1da97b41d81f9426a
        #item_base_name: salt-minion-2014.7.1-1.fc21.x86_64.rpms.zip
        #item_content_hash: md5=79e34d62ab3634fe53d778e1ab068d11

    # TODO: There is own vagrant image: 'uvsmtid/fedora-21-server-minimal'.
    # Downloaded on Vagrant virtual box 'hansode/fedora-21-server-x86_64':
    #   sudo yum install --downloadonly --downloaddir=salt-master.rpms/ salt-master
    # There are neither `zip` nor `tar` command on minimal F21.
    salt-master_downloaded_rpms_with_dependencies_2014.7.1-1.fc21.x86_64:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/salt
        item_base_name: salt-master-2014.7.1-1.fc21.x86_64.rpms.tar
        item_content_hash: md5=f5814046b76dcfaa7157eac6fcd56990
        #item_base_name: salt-master-2014.7.1-1.fc21.x86_64.rpms.zip
        #item_content_hash: md5=a3dca277ba62d72eec31ee709cce0acd

    ###########################################################################
    # Salt for CentOS 7 = platform `rhel7`

    {% if False %}

    # Previous Salt version `2014.7.1`.
    {% elif False %}

    # TODO: Provide only `salt-minion` package.
    # NOTE: It has the same dependencies with `salt-master`.
    #
    # Downloaded on Vagrant virtual box 'uvsmtid/centos-7.0-minimal':
    #   sudo yum install --downloadonly --downloaddir=salt-minion.rpms/ salt-minion
    # Note that CentOS 7.0 minimal does not have `zip`/`unzip`,
    # only `tar` (and `gzip`/`gunzip`).
    salt-minion_downloaded_rpms_with_dependencies_2014.7.1-1.el7.x86_64:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/salt
        item_base_name: salt-minion-2014.7.1-1.el7.x86_64.rpms.tar
        item_content_hash: md5=4781e6b4e73bf9b15da27396631946cf

    # TODO: Provide only `salt-master` package.
    # NOTE: It has the same dependencies with `salt-minion`.
    #
    # Downloaded on Vagrant virtual box 'uvsmtid/centos-7.0-minimal':
    #   sudo yum install --downloadonly --downloaddir=salt-master.rpms/ salt-master
    # Note that CentOS 7.0 minimal does not have `zip`/`unzip`,
    # only `tar` (and `gzip`/`gunzip`).
    salt-master_downloaded_rpms_with_dependencies_2014.7.1-1.el7.x86_64:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/salt
        item_base_name: salt-master-2014.7.1-1.el7.x86_64.rpms.tar
        item_content_hash: md5=84593d8c077b10253c062ff3b95ecbe1

    # Latest Salt version `2015.5.10`.
    {% elif True %}

    salt-rpms-2015.5.10-1.el7.x86_64.tar:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/salt
        item_base_name: salt-rpms-2015.5.10-1.el7.x86_64.tar
        item_content_hash: md5=fe08c88ee2c4c1aaf419ff1ea534a08b

    salt-master-2015.5.10-1.el7.noarch.rpm:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/salt
        item_base_name: salt-master-2015.5.10-1.el7.noarch.rpm
        item_content_hash: md5=f6cd4f0697d25c7611d7b90869ba12fa

    salt-minion-2015.5.10-1.el7.noarch.rpm:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/salt
        item_base_name: salt-minion-2015.5.10-1.el7.noarch.rpm
        item_content_hash: md5=ded1f386ec0e8a0eca6cb0b7af9ee04b

    {% endif %}

    ###########################################################################
    # Salt for CentOS 5 = platform `rhel5`

    {% if False %}

    # Previous Salt version `2015.5.3`.
    {% elif False %}

    # Common dependencies for both `salt-minion` and `salt-master`
    # NOTE: After downloading with dependencies `salt*` pacakges,
    #       the following command shows that all dependencies are the same:
    #         for DIR in salt-master.rpms salt-minion.rpms salt.rpms ; do (cd $DIR ; md5sum * | sort ; cd -) > $DIR.sort.list.txt ; done
    # NOTE: Download requires enabling official Salt repo for RHEL5:
    #         https://copr.fedoraproject.org/coprs/saltstack/salt-el5/
    # Downloaded on Vagrant virtual box 'uvsmtid/centos-5.5-minimal':
    #   sudo yum install yum-downloadonly
    #   sudo yum install --downloadonly --downloaddir=salt.rpms/ salt
    #   cd salt.rpms/
    #   tar -cvf ../salt.rpms-VERSION.tar *
    salt_downloaded_rpms_with_dependencies_2015.5.3-4.el5.x86_64.tar:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/salt
        item_base_name: salt-2015.5.3-4.el5.x86_64.tar
        item_content_hash: md5=4b2f53abd0b54fcda7545badb0207e66

    # NOTE: `salt-master` has the same dependencies with `salt-minion`.
    #
    # NOTE: Download requires enabling official Salt repo for RHEL5:
    #         https://copr.fedoraproject.org/coprs/saltstack/salt-el5/
    # Downloaded on Vagrant virtual box 'uvsmtid/centos-5.5-minimal':
    #   sudo yum install yum-downloadonly
    #   sudo yum install --downloadonly --downloaddir=salt-master.rpms/ salt-master
    #   # See downloading `salt` package only - compare the same dependencies.
    salt-master-2015.5.3-4.noarch.el5.rpm:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/salt
        item_base_name: salt-master-2015.5.3-4.noarch.el5.rpm
        item_content_hash: md5=490caab1f2ca831075ef15154ce12562

    # NOTE: `salt-minion` has the same dependencies with `salt-master`.
    #
    # NOTE: Download requires enabling official Salt repo for RHEL5:
    #         https://copr.fedoraproject.org/coprs/saltstack/salt-el5/
    # Downloaded on Vagrant virtual box 'uvsmtid/centos-5.5-minimal':
    #   sudo yum install yum-downloadonly
    #   sudo yum install --downloadonly --downloaddir=salt-minion.rpms/ salt-minion
    #   # See downloading `salt` package only - compare the same dependencies.
    salt-minion-2015.5.3-4.noarch.el5.rpm:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/salt
        item_base_name: salt-minion-2015.5.3-4.noarch.el5.rpm
        item_content_hash: md5=1a88c3d858d82733acb3a667de467041

    # Latest Salt version `2015.5.10`.
    {% elif True %}

    salt-rpms-2015.5.10-1.el5.x86_64.tar:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/salt
        item_base_name: salt-rpms-2015.5.10-1.el5.x86_64.tar
        item_content_hash: md5=d4eae5dcfbf76c1737eb16364e9b7fe8

    salt-master-2015.5.10-1.el5.noarch.rpm:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/salt
        item_base_name: salt-master-2015.5.10-1.el5.noarch.rpm
        item_content_hash: md5=993b091e7984d5917d059bc5d06355b8

    salt-minion-2015.5.10-1.el5.noarch.rpm:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/salt
        item_base_name: salt-minion-2015.5.10-1.el5.noarch.rpm
        item_content_hash: md5=5197b47c7cff3014eea99ee2df98d104

    {% endif %}

    # Update to 2016.3.2 for Windows support of
    # `cmd.run` with `runas` option.
    {% if False %}
    Salt-Minion-2015.5.11-AMD64-Setup.exe:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/salt
        item_base_name: Salt-Minion-2015.5.11-AMD64-Setup.exe
        item_content_hash: md5=666697105e366191b7668dbf76e29ddc
    {% else %}
    Salt-Minion-2016.3.2-AMD64-Setup.exe:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/salt
        item_base_name: Salt-Minion-2016.3.2-AMD64-Setup.exe
        item_content_hash: md5=2c140f5adbae52bed40f58adec160296
    {% endif %}

###############################################################################
# EOF
###############################################################################

