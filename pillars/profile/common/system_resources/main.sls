
###############################################################################
#

# TODO: Consider adding definitions of all software versions on `depository-role`.
#       This is to be able to rebase versions relatively easily
#       (i.e. manually putting files on `depository-role`, changing the definition
#       and re-running installation state).

# TODO: Consider adding definitions of all software versions which is built
#       within project.
#       This is to be able to deploy specified versions (not just the latest)
#       of software for testing. In fact, this can also help to create
#       validation logic which ensures specific software versions.

# NOTE: The name of the item is arbitrary. However, follow the guideline:
#         [general name]_[specific name]_[version]_[architecture]_[platform]
#       For example:
#         java_jre_7_64_bit_windows
#
#         general name:  java
#         specific name: jre
#         version:       7
#         architecture:  64_bit
#         platform:      windows

registered_content_items:

    # Jenkins YUM repository key (to verify signed RPM packages).
    # Downloadable from:
    #   http://pkg.jenkins-ci.org/redhat/
    jenkins_yum_repository_rpm_verification_key:
        resource_repository: shared_content
        bootstrap_use_cases: True
        enable_content_validation: True
        # In addition to importing RPM key, this enables configuration of
        # Jenkins repository:
        enable_installation: True
        item_parent_dir_path: distrib/jenkins
        item_base_name: jenkins-ci.org.key
        item_content_hash: md5=9fa06089848262c5a6383ec27fdd2575

    # Jenkins: Cygpath Plugin
    # Downloadable from:
    #   https://wiki.jenkins-ci.org/display/JENKINS/Cygpath+Plugin
    # Direct link:
    #   http://updates.jenkins-ci.org/download/plugins/cygpath/1.5/cygpath.hpi
    jenkins_cygpath_plugin:
        resource_repository: shared_content
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: distrib/jenkins
        item_base_name: cygpath.hpi
        item_content_hash: md5=fec9d1b734089f8fae0e9755f2a1bc75
        plugin_name: cygpath

    # Jenkins: Maven Project Plugin
    # Downloadable from:
    #   https://wiki.jenkins-ci.org/display/JENKINS/Maven+Project+Plugin
    # Direct link:
    #   http://updates.jenkins-ci.org/download/plugins/maven-plugin/2.8/maven-plugin.hpi
    jenkins_maven-plugin_plugin:
        resource_repository: shared_content
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: distrib/jenkins
        item_base_name: maven-plugin.hpi
        item_content_hash: md5=d05426ca23528ff782cc3bf926da999e
        plugin_name: maven-plugin

    # Jenkins: M2 Release Plugin
    # Downloadable from:
    #   https://wiki.jenkins-ci.org/display/JENKINS/M2+Release+Plugin
    # Direct link:
    #   http://updates.jenkins-ci.org/download/plugins/m2release/0.14.0/m2release.hpi
    jenkins_m2release_plugin:
        resource_repository: shared_content
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: distrib/jenkins
        item_base_name: m2release.hpi
        item_content_hash: md5=fde761d8d19f2154a24461d005340e91
        plugin_name: m2release

    # Jenkins: Git Client Plugin
    # Downloadable from:
    #   https://wiki.jenkins-ci.org/display/JENKINS/Git+Client+Plugin
    # Direct link:
    #   http://updates.jenkins-ci.org/download/plugins/git-client/1.16.1/git-client.hpi
    jenkins_git-client_plugin:
        resource_repository: shared_content
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: distrib/jenkins
        item_base_name: git-client.hpi
        item_content_hash: md5=5331dd9f233228bca6486f51e21bf6ac
        plugin_name: git-client

    # Jenkins: Git Plugin
    # Downloadable from:
    #   https://wiki.jenkins-ci.org/display/JENKINS/Git+Plugin
    # Direct link:
    #   http://updates.jenkins-ci.org/download/plugins/git/2.3.4/git.hpi
    jenkins_git_plugin:
        resource_repository: shared_content
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: distrib/jenkins
        item_base_name: git.hpi
        item_content_hash: md5=e3ead2aa0ba8b7666566e0e3dea964e3
        plugin_name: git

    # Jenkins: SCM API Plugin
    # Downloadable from:
    #   https://wiki.jenkins-ci.org/display/JENKINS/SCM+API+Plugin
    # Direct link:
    #   http://updates.jenkins-ci.org/download/plugins/scm-api/0.2/scm-api.hpi
    jenkins_scm-api_plugin:
        resource_repository: shared_content
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: distrib/jenkins
        item_base_name: scm-api.hpi
        item_content_hash: md5=9574c07bf6bfd02a57b451145c870f0e
        plugin_name: scm-api

    # Nexus maven repository manager (community edition).
    # Downloadable from:
    #   http://www.sonatype.org/nexus/go/
    nexus_maven_repository_manager:
        resource_repository: shared_content
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: distrib/nexus
        item_base_name: nexus-bundle.tar.gz
        # Version 2.11.1-01: `nexus-2.11.1-01-bundle.tar.gz`
        item_content_hash: md5=fec9d1b734089f8fae0e9755f2a1bc75
        nexus_bundle_version_infix: '2.11.1-01'

    # 7zip archiver.
    # 7-zip installer.
    # Downloadable from:
    #   http://www.7-zip.org/download.html
    7zip_64_bit_windows:
        resource_repository: shared_content
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: distrib/7zip
        item_base_name: 7z920-x64.msi
        item_content_hash: md5=cac92727c33bec0a79965c61bbb1c82f

    # Pre-downloaded Cygwin package with required components.
    cygwin_package_64_bit_windows:
        resource_repository: shared_content
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        installation_directory: 'C:\cygwin64'
        # Checking existance of this file confirms existing installation.
        completion_file_indicator: 'C:\cygwin64\installed.txt'
        item_parent_dir_path: distrib/cygwin
        item_base_name: 2014-02-13-T03-11-40.056190700.cygwin.distrib.zip
        item_content_hash: md5=9c37559140d5510ce768f7b0fb7daff0
        # See docs for CYGWIN environment variable:
        #   http://cygwin.com/cygwin-ug-net/using-cygwinenv.html
        CYGWIN_env_var_items_list:
            # Windows NTFS native symlink can be used in both inside and
            # outside of Cygwin:
            - winsymlinks:nativestrict
    # Another way to use cygwin is to create a local mirror and use cygwin
    # setup utility. However, it uses over 20+G of space.
    # Cygwin setup utility downloadable from:
    #   http://cygwin.com/install.html
    # See also:
    #   https://sourceware.org/cygwin-apps/package-server.html
    # Available mirrors:
    #   http://cygwin.com/mirrors.html
    # For example, this command worked:
    #   rsync -vaz rsync://mirrors.kernel.org/sourceware/cygwin/x86_64/ /var/www/html/depository-role/content/distrib/cygwin/x86_64/

    oracle_jdk-7u71-linux-x64.rpm:
        resource_repository: shared_content
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: distrib/java
        item_base_name: jdk-7u71-linux-x64.rpm
        item_content_hash: md5=f9dafcc0bd52f085c8b0894c27b39d10

    oracle_jdk-7u65-linux-x64.rpm:
        resource_repository: shared_content
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: distrib/java
        item_base_name: jdk-7u65-linux-x64.rpm
        item_content_hash: md5=f5a975d77d35bc7713a8806090f5f9e2

###############################################################################
# EOF
###############################################################################

