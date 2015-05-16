
###############################################################################
#

system_resources:

    # Downloaded on Vagrant virtual box 'hansode/fedora-21-server-x86_64':
    #   sudo yum install --downloadonly --downloaddir=salt-minion.rpms/ salt-minion
    # Is there `zip` or `tar` on Fedora 21 minimal?.
    salt-minion_downloaded_rpms_with_dependencies_2014.7.1-1.fc21.x86_64:
        resource_repository: common-resources
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
        resource_repository: common-resources
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
        resource_repository: common-resources
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
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: distrib/salt/bootstrap
        item_base_name: salt-master-2014.7.1-1.el7.x86_64.rpms.tar
        item_content_hash: md5=84593d8c077b10253c062ff3b95ecbe1

    # Downloaded on Vagrant virtual box 'uvsmtid/centos-5.5-minimal':
    #   sudo yum install yum-downloadonly
    #   sudo yum install --downloadonly --downloaddir=salt-minion.rpms/ salt-minion
    # TODO: CentOS 5.5 minimal DOES have `tar` (and gzip`/`gunzip`),
    #       but this is `zip`.
    salt-minion_downloaded_rpms_with_dependencies_2014.7.1-1.el5.x86_64:
        resource_repository: common-resources
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
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: distrib/salt/bootstrap
        item_base_name: salt-master-2014.7.1-1.el5.x86_64.rpms.zip
        item_content_hash: md5=76dbefa4c6703a5bfd4f78ea9571c42e

###############################################################################
# EOF
###############################################################################

