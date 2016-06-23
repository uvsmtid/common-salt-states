
###############################################################################
#

system_resources:

    # NOTE: Sonarqube is not from Fedora default repositories.
    #       Therefore, it is a moving target package is installed
    #       (even major version updates may be selected).
    #       To avoid issues, fix the version of Sonarqube by using
    #       this pre-downloaded RPM.
    sonar_pre_downloaded_rpm:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/sonarqube
        item_base_name: sonar-5.6-1.noarch.rpm
        item_content_hash: md5=cd251c613ca20ca308f63140e35eb210

    # TODO: Use format `sonar_[name]_plugin` - see word order in original `item_base_name`.
    sonar_plugin_checkstyle:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/sonarqube
        item_base_name: sonar-checkstyle-plugin-2.4.jar
        # TODO: item_content_hash

    # TODO: Use format `sonar_[name]_plugin` - see word order in original `item_base_name`.
    sonar_plugin_findbugs:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/sonarqube
        item_base_name: sonar-findbugs-plugin-3.3.jar
        # TODO: item_content_hash

    sonar_java_plugin:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/sonarqube
        item_base_name: sonar-java-plugin-3.9.jar
        item_content_hash: db224331b6753d63cb31f2b58c93914c

    # TODO: Use format `sonar_[name]_plugin` - see word order in original `item_base_name`.
    sonar_plugin_pdf_report:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/sonarqube
        item_base_name: sonar-pdfreport-plugin-1.4.jar
        # TODO: item_content_hash

    # TODO: Use format `sonar_[name]_plugin` - see word order in original `item_base_name`.
    sonar_plugin_pmd:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/sonarqube
        item_base_name: sonar-pmd-plugin-2.5.jar
        # TODO: item_content_hash

    sonar_git_plugin:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/sonarqube
        item_base_name: sonar-scm-git-plugin-1.1.jar
        item_content_hash: md5=120a72450c85957c4fbc17c3b07dda2e

###############################################################################
# EOF
###############################################################################

