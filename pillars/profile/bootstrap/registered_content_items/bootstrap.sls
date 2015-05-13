
###############################################################################
#

registered_content_items:
    # Downloaded on Vagrant virtual box 'hansode/fedora-21-server-x86_64':
    #   sudo yum install --downloadonly --downloaddir=salt-minion.rpms/ salt-minion
    # Is there `zip` or `tar` on Fedora 21 minimal?.
    salt-minion_downloaded_rpms_with_dependencies_2014.7.1-1.fc21.x86_64:
        resource_repository: shared_content
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: distrib/salt/bootstrap
        item_base_name: salt-minion-2014.7.1-1.fc21.x86_64.rpms.tar
        item_content_hash: md5=6bb9952118afc6c1da97b41d81f9426a
        #item_base_name: salt-minion-2014.7.1-1.fc21.x86_64.rpms.zip
        #item_content_hash: md5=79e34d62ab3634fe53d778e1ab068d11

    # Downloaded on Vagrant virtual box 'hansode/fedora-21-server-x86_64':
    #   sudo yum install --downloadonly --downloaddir=salt-master.rpms/ salt-master
    # Is there `zip` or `tar` on Fedora 21 minimal?.
    salt-master_downloaded_rpms_with_dependencies_2014.7.1-1.fc21.x86_64:
        resource_repository: shared_content
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: distrib/salt/bootstrap
        item_base_name: salt-master-2014.7.1-1.fc21.x86_64.rpms.tar
        item_content_hash: md5=f5814046b76dcfaa7157eac6fcd56990
        #item_base_name: salt-master-2014.7.1-1.fc21.x86_64.rpms.zip
        #item_content_hash: md5=a3dca277ba62d72eec31ee709cce0acd

    # Downloaded on Vagrant virtual box 'uvsmtid/centos-7.0-minimal':
    #   sudo yum install --downloadonly --downloaddir=salt-minion.rpms/ salt-minion
    # Note that CentOS 7.0 minimal does not have `zip`/`unzip`,
    # only `tar` (and `gzip`/`gunzip`).
    salt-minion_downloaded_rpms_with_dependencies_2014.7.1-1.el7.x86_64:
        resource_repository: shared_content
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: distrib/salt/bootstrap
        item_base_name: salt-minion-2014.7.1-1.el7.x86_64.rpms.tar
        item_content_hash: md5=4781e6b4e73bf9b15da27396631946cf

    # Downloaded on Vagrant virtual box 'uvsmtid/centos-7.0-minimal':
    #   sudo yum install --downloadonly --downloaddir=salt-master.rpms/ salt-master
    # Note that CentOS 7.0 minimal does not have `zip`/`unzip`,
    # only `tar` (and `gzip`/`gunzip`).
    salt-master_downloaded_rpms_with_dependencies_2014.7.1-1.el7.x86_64:
        resource_repository: shared_content
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: distrib/salt/bootstrap
        item_base_name: salt-master-2014.7.1-1.el7.x86_64.rpms.tar
        item_content_hash: md5=84593d8c077b10253c062ff3b95ecbe1

    # This is required to install Salt on CentOS 5.5 (EPEL package is
    # discontinued).
    # Downloaded on Vagrant virtual box 'uvsmtid/centos-5.5-minimal':
    #   sudo yum install yum-downloadonly
    #   sudo yum install --downloadonly --downloaddir=python26-distribute.rpms/ python26-distribute
    # TODO: CentOS 5.5 minimal DOES have `tar` (and gzip`/`gunzip`),
    #       but this is `zip`.
    python26-distribute_downloaded_rpms_with_dependencies_0.6.10-4.el5.x86_64:
        resource_repository: shared_content
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: distrib/salt/bootstrap
        item_base_name: python26-distribute-0.6.10-4.el5.x86_64.rpms.zip
        item_content_hash: md5=8406a25dbd3bacdf87b52acaec096c8e

    # Downloaded on Vagrant virtual box 'uvsmtid/centos-5.5-minimal':
    #   sudo yum install yum-downloadonly
    #   sudo yum install --downloadonly --downloaddir=salt-minion.rpms/ salt-minion
    # TODO: CentOS 5.5 minimal DOES have `tar` (and gzip`/`gunzip`),
    #       but this is `zip`.
    salt-minion_downloaded_rpms_with_dependencies_2014.7.1-1.el5.x86_64:
        resource_repository: shared_content
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: distrib/salt/bootstrap
        item_base_name: salt-minion-2014.7.1-1.el5.x86_64.rpms.zip
        item_content_hash: md5=fa1d8b766d48cd35964df123afde7813

    # Downloaded on Vagrant virtual box 'uvsmtid/centos-5.5-minimal':
    #   sudo yum install yum-downloadonly
    #   sudo yum install --downloadonly --downloaddir=salt-master.rpms/ salt-master
    # TODO: CentOS 5.5 minimal DOES have `tar` (and gzip`/`gunzip`),
    #       but this is `zip`.
    salt-master_downloaded_rpms_with_dependencies_2014.7.1-1.el5.x86_64:
        resource_repository: shared_content
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: distrib/salt/bootstrap
        item_base_name: salt-master-2014.7.1-1.el5.x86_64.rpms.zip
        item_content_hash: md5=76dbefa4c6703a5bfd4f78ea9571c42e

    # PyYAML for 'uvsmtid/centos-7.0-minimal'.
    #   sudo yum install --downloadonly --downloaddir=. PyYAML
    PyYAML-3.10-11.el7.x86_64.rpms.tar:
        resource_repository: shared_content
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: distrib/salt/bootstrap
        item_base_name: PyYAML-3.10-11.el7.x86_64.rpms.tar
        item_content_hash: md5=258e9621d85ffe2ff682dbd4b1a8083b

    # PyYAML for 'uvsmtid/centos-5.5-minimal'.
    # Note that EPEL repository should be enabled.
    #   sudo yum install yum-downloadonly
    #   sudo yum install --downloadonly --downloaddir=. PyYAML
    PyYAML-3.09-10.el5.x86_64.rpms.tar:
        resource_repository: shared_content
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: distrib/salt/bootstrap
        item_base_name: PyYAML-3.09-10.el5.x86_64.rpms.tar
        item_content_hash: md5=10c7855bdaafae965725d697d99d6b6b

    # EPEL5 YUM repository key (to verify signed RPM packages).
    # Downloadable from:
    #     https://fedoraproject.org/keys
    rhel5_epel5_yum_repository_rpm_verification_key:
        resource_repository: shared_content
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: distrib/epel
        item_base_name: RPM-GPG-KEY-EPEL-5.217521F6.key.txt
        item_content_hash: md5=895459095f6dda788e022bb15a177a73

    # EPEL5 YUM repository key (to verify signed RPM packages).
    # Downloadable from:
    #     https://fedoraproject.org/keys
    rhel5_epel7_yum_repository_rpm_verification_key:
        resource_repository: shared_content
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: distrib/epel
        item_base_name: RPM-GPG-KEY-EPEL-7.352C64E5.txt
        item_content_hash: md5=2bab86176f606dc3a89deb55c8fbb41a

    # `unzip` package for CentOS 7.0 downloaded on minimal install OS:
    # sudo yum install --downloadonly --downloaddir=. unzip
    unzip-6.0-13.el7.x86_64.rpm:
        resource_repository: shared_content
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: distrib/salt/bootstrap
        item_base_name: unzip-6.0-13.el7.x86_64.rpm
        item_content_hash: md5=abbb421ceca1a5c74e1b09609c97688e

    # `zip` package for CentOS 7.0 downloaded on minimal install OS:
    # sudo yum install --downloadonly --downloaddir=. zip
    zip-3.0-10.el7.x86_64.rpm:
        resource_repository: shared_content
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: distrib/salt/bootstrap
        item_base_name: zip-3.0-10.el7.x86_64.rpm
        item_content_hash: md5=4623f947ddc141f4d0f8e0bf4bf10529

    # PostgreSQL YUM repo GPG RPM key.
    rhel5_postgresql_yum_repository_rpm_verification_key:
        resource_repository: shared_content
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: distrib/postgresql
        item_base_name: RPM-GPG-KEY-PGDG-93
        item_content_hash: md5=78b5db170d33f80ad5a47863a7476b22

    # CentOS 5 base and updates YUM repos GPG RPM key.
    rhel5_centos5_base_updates_yum_repository_rpm_verification_key:
        resource_repository: shared_content
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: distrib/rhel5
        item_base_name: RPM-GPG-KEY-CentOS-5
        item_content_hash: md5=5f7bafa185a848e2f689dba1918dcf64

    # CentOS 7 base and updats YUM repos GPG RPM key.
    rhel7_centos7_base_updates_yum_repository_rpm_verification_key:
        resource_repository: shared_content
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: distrib/rhel7
        item_base_name: RPM-GPG-KEY-CentOS-7
        item_content_hash: md5=c45e7e322681292ce4c1d2a6d392c4b5

###############################################################################
# EOF
###############################################################################

