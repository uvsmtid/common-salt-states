
###############################################################################
#

system_resources:

    # NOTE: Some projects have to use specific version of Maven
    #       (due to some propriatery or even open Maven plugin issues).
    maven_pre_downloaded_rpm:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/maven
        item_base_name: apache-maven-3.2.5-bin.tar.gz
        item_content_hash: md5=b2d88f02bd3a08a9df1f0b0126ebd8dc

###############################################################################
# EOF
###############################################################################

