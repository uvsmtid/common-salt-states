
###############################################################################
#

system_resources:

    # This is just an example.
    {% if False %}
    # Jenkins YUM repository key (to verify signed RPM packages).
    # Downloadable from:
    #   http://pkg.jenkins-ci.org/redhat/
    jenkins_yum_repository_rpm_verification_key:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        # In addition to importing RPM key, this enables configuration of
        # Jenkins repository:
        enable_installation: True
        item_parent_dir_path: common/jenkins
        item_base_name: jenkins-ci.org.key
        item_content_hash: md5=9fa06089848262c5a6383ec27fdd2575
    {% endif %}

    sonar_plugin_checkstyle:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/sonarqube
        item_base_name: sonar-checkstyle-plugin-2.4.jar

    sonar_plugin_findbugs:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/sonarqube
        item_base_name: sonar-findbugs-plugin-3.3.jar

    sonar_plugin_java:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/sonarqube
        item_base_name: sonar-java-plugin-3.9.jar

    sonar_plugin_pdf_report:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/sonarqube
        item_base_name: sonar-pdfreport-plugin-1.4.jar

    sonar_plugin_pmd:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/sonarqube
        item_base_name: sonar-pmd-plugin-2.5.jar

###############################################################################
# EOF
###############################################################################

