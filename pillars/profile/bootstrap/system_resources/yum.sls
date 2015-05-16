
###############################################################################
#

system_resources:

    # EPEL5 YUM repository key (to verify signed RPM packages).
    # Downloadable from:
    #     https://fedoraproject.org/keys
    rhel5_epel5_yum_repository_rpm_verification_key:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/yum/epel
        item_base_name: RPM-GPG-KEY-EPEL-5.217521F6.key.txt
        item_content_hash: md5=895459095f6dda788e022bb15a177a73

    # EPEL5 YUM repository key (to verify signed RPM packages).
    # Downloadable from:
    #     https://fedoraproject.org/keys
    rhel5_epel7_yum_repository_rpm_verification_key:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/yum/epel
        item_base_name: RPM-GPG-KEY-EPEL-7.352C64E5.key.txt
        item_content_hash: md5=2bab86176f606dc3a89deb55c8fbb41a

    # PostgreSQL YUM repo GPG RPM key.
    rhel5_postgresql_yum_repository_rpm_verification_key:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/yum/postgresql
        item_base_name: RPM-GPG-KEY-PGDG-93
        item_content_hash: md5=78b5db170d33f80ad5a47863a7476b22

    # CentOS 5 base and updates YUM repos GPG RPM key.
    rhel5_centos5_base_updates_yum_repository_rpm_verification_key:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/yum/rhel5
        item_base_name: RPM-GPG-KEY-CentOS-5
        item_content_hash: md5=5f7bafa185a848e2f689dba1918dcf64

    # CentOS 7 base and updats YUM repos GPG RPM key.
    rhel7_centos7_base_updates_yum_repository_rpm_verification_key:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/yum/rhel7
        item_base_name: RPM-GPG-KEY-CentOS-7
        item_content_hash: md5=c45e7e322681292ce4c1d2a6d392c4b5

    # OpenStack Juno Fedora 21 and EPEL-7 YUM repos GPG RPM key.
    openstack_juno_repository_rpm_verification_key:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: bootstrap/yum/openstack
        item_base_name: RPM-GPG-KEY-RDO-Juno
        item_content_hash: md5=b401244ed3cbc53d9f2b921f9b4d3086

###############################################################################
# EOF
###############################################################################

