
###############################################################################
#

# TODO: Consider adding definitions of all software versions on `depository_role`.
#       This is to be able to rebase versions relatively easily
#       (i.e. manually putting files on `depository_role`, changing the definition
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

system_resources:

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

    # Jenkins: Cygpath Plugin
    # Downloadable from:
    #   https://wiki.jenkins-ci.org/display/JENKINS/Cygpath+Plugin
    # Direct link:
    #   http://updates.jenkins-ci.org/download/plugins/cygpath/1.5/cygpath.hpi
    jenkins_cygpath_plugin:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/jenkins
        item_base_name: cygpath.v1.5.hpi
        item_content_hash: md5=fec9d1b734089f8fae0e9755f2a1bc75
        plugin_name: cygpath

    # Jenkins: Maven Project Plugin
    # Downloadable from:
    #   https://wiki.jenkins-ci.org/display/JENKINS/Maven+Project+Plugin
    # Direct link:
    #   http://updates.jenkins-ci.org/download/plugins/maven-plugin/2.8/maven-plugin.hpi
    jenkins_maven-plugin_plugin:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/jenkins
        item_base_name: maven-plugin.v2.12.hpi
        item_content_hash: md5=a66e444d4d4453899b661cd6079a186b
        plugin_name: maven-plugin

    # Jenkins: M2 Release Plugin
    # Downloadable from:
    #   https://wiki.jenkins-ci.org/display/JENKINS/M2+Release+Plugin
    # Direct link:
    #   http://updates.jenkins-ci.org/download/plugins/m2release/0.14.0/m2release.hpi
    jenkins_m2release_plugin:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/jenkins
        item_base_name: m2release.v0.14.0.hpi
        item_content_hash: md5=fde761d8d19f2154a24461d005340e91
        plugin_name: m2release

    # Jenkins: Git Client Plugin
    # Downloadable from:
    #   https://wiki.jenkins-ci.org/display/JENKINS/Git+Client+Plugin
    # Direct link:
    #   http://updates.jenkins-ci.org/download/plugins/git-client/1.16.1/git-client.hpi
    jenkins_git-client_plugin:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/jenkins
        item_base_name: git-client.v1.16.1.hpi
        item_content_hash: md5=5331dd9f233228bca6486f51e21bf6ac
        plugin_name: git-client

    # Jenkins: Parameterized Trigger Plugin
    # Downloadable from:
    #   https://wiki.jenkins-ci.org/display/JENKINS/Parameterized+Trigger+Plugin
    # Direct link:
    #   http://updates.jenkins-ci.org/download/plugins/parameterized-trigger/2.26/parameterized-trigger.hpi
    jenkins_parameterized-trigger_plugin:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/jenkins
        item_base_name: parameterized-trigger.v2.26.hpi
        item_content_hash: md5=c88936fb6d5885d3aef93439ead9ae76
        plugin_name: parameterized-trigger

    # Jenkins: Rebuild Plugin
    # Downloadable from:
    #   https://wiki.jenkins-ci.org/display/JENKINS/Rebuild+Plugin
    # Direct link:
    #   http://updates.jenkins-ci.org/download/plugins/rebuild/1.25/rebuild.hpi
    jenkins_rebuild_plugin:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/jenkins
        item_base_name: rebuild.v1.25.hpi
        item_content_hash: md5=103bc7fcf80864774438d7c9a63ca8f2
        plugin_name: rebuild

    # Jenkins: Copy Artifact Plugin
    # Downloadable from:
    #  https://wiki.jenkins-ci.org/display/JENKINS/Copy+Artifact+Plugin
    # Direct link:
    #  http://updates.jenkins-ci.org/download/plugins/copyartifact/1.35.2/copyartifact.hpi
    jenkins_copyartifact_plugin:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/jenkins
        item_base_name: copyartifact.v1.35.2.hpi
        item_content_hash: md5=aa1ad17560f526b16ae7fc2bfad955c5
        plugin_name: copyartifact

    # Jenkins: Promoted Builds Plugin
    # Downloadable from:
    #  https://wiki.jenkins-ci.org/display/JENKINS/Promoted+Builds+Plugin
    # Direct link:
    #  http://updates.jenkins-ci.org/download/plugins/promoted-builds/2.21/promoted-builds.hpi
    jenkins_promoted-builds_plugin:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/jenkins
        item_base_name: promoted-builds.v2.21.hpi
        item_content_hash: md5=514275e441a9e92c23ca56dddf131b6a
        plugin_name: promoted-builds

    # Jenkins: Join Plugin
    # Downloadable from:
    #  https://wiki.jenkins-ci.org/display/JENKINS/Join+Plugin
    # Direct link:
    #  http://updates.jenkins-ci.org/download/plugins/join/1.16/join.hpi
    jenkins_join_plugin:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/jenkins
        item_base_name: join.v1.16.hpi
        item_content_hash: md5=5b4dc12ceca80a8c6aa4f152c2ac265a
        plugin_name: join

    # Jenkins: jQuery Plugin
    # Downloadable from:
    #   https://wiki.jenkins-ci.org/display/JENKINS/jQuery+Plugin
    # Direct link:
    #   http://updates.jenkins-ci.org/download/plugins/jquery/1.11.2-0/jquery.hpi
    jenkins_jquery_plugin:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/jenkins
        item_base_name: jquery.v1.11.2-0.hpi
        item_content_hash: md5=9da63f0ce212e1e8b44a68252739dbaa
        plugin_name: jquery

    # Jenkins: Build Pipeline Plugin
    # Downloadable from:
    #   https://wiki.jenkins-ci.org/display/JENKINS/Build+Pipeline+Plugin
    # Direct link:
    #   http://updates.jenkins-ci.org/download/plugins/build-pipeline-plugin/1.4.7/build-pipeline-plugin.hpi
    jenkins_build-pipeline-plugin_plugin:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/jenkins
        item_base_name: build-pipeline-plugin.v1.4.7.hpi
        item_content_hash: md5=4bc24f01d487ab356cac5d9edce9a23b
        plugin_name: build-pipeline-plugin

    # Jenkins: Git Plugin
    # Downloadable from:
    #   https://wiki.jenkins-ci.org/display/JENKINS/Git+Plugin
    # Direct link:
    #   http://updates.jenkins-ci.org/download/plugins/git/2.3.4/git.hpi
    jenkins_git_plugin:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/jenkins
        item_base_name: git.v2.3.4.hpi
        item_content_hash: md5=e3ead2aa0ba8b7666566e0e3dea964e3
        plugin_name: git

    # Jenkins: SCM API Plugin
    # Downloadable from:
    #   https://wiki.jenkins-ci.org/display/JENKINS/SCM+API+Plugin
    # Direct link:
    #   http://updates.jenkins-ci.org/download/plugins/scm-api/0.2/scm-api.hpi
    jenkins_scm-api_plugin:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/jenkins
        item_base_name: scm-api.v0.2.hpi
        item_content_hash: md5=9574c07bf6bfd02a57b451145c870f0e
        plugin_name: scm-api

    # Jenkins: EnvInject Plugin
    # Downloadable from:
    #   https://wiki.jenkins-ci.org/display/JENKINS/EnvInject+Plugin
    # Direct link:
    #   http://updates.jenkins-ci.org/latest/envinject.hpi
    jenkins_envinject_plugin:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/jenkins
        item_base_name: envinject.v1.91.3.hpi
        item_content_hash: md5=723f9998ce3f7404e3e77f62e5670eb3
        plugin_name: envinject

    # Jenkins: Multiple SCMs Plugin
    # Downloadable from:
    #   https://wiki.jenkins-ci.org/display/JENKINS/Multiple+SCMs+Plugin
    # Direct link:
    #   http://updates.jenkins-ci.org/latest/multiple-scms.hpi
    jenkins_multiple-scms_plugin:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/jenkins
        item_base_name: multiple-scms.v0.5.hpi
        item_content_hash: md5=a9760547ad0c820f694af6bd2f652958
        plugin_name: multiple-scms

    # Jenkins: Timestamper
    # Downloadable from:
    #   https://wiki.jenkins-ci.org/display/JENKINS/Timestamper
    # Direct link:
    #   http://updates.jenkins-ci.org/latest/timestamper.hpi
    jenkins_timestamper_plugin:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/jenkins
        item_base_name: timestamper.v1.7.2.hpi
        item_content_hash: md5=54318348886da3fce3f46b1daec29287
        plugin_name: timestamper

    # Jenkins: Build Blocker Plugin
    # Downloadable from:
    #   https://wiki.jenkins-ci.org/display/JENKINS/Build+Blocker+Plugin
    # Direct link:
    #   http://updates.jenkins-ci.org/latest/build-blocker-plugin.hpi
    jenkins_build-blocker-plugin_plugin:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/jenkins
        item_base_name: build-blocker-plugin.v1.7.1.hpi
        item_content_hash: md5=31d6dbdd21d10861f7a960f71f368384
        plugin_name: build-blocker-plugin

    # Jenkins: Modern Status Plugin
    # Downloadable from:
    #   https://wiki.jenkins-ci.org/display/JENKINS/Modern+Status+Plugin
    # Direct link:
    #   http://updates.jenkins-ci.org/latest/modernstatus.hpi
    jenkins_modernstatus_plugin:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/jenkins
        item_base_name: modernstatus.v1.2.hpi
        item_content_hash: md5=f62c468ca9561931dea89676084f30f1
        plugin_name: modernstatus

    # Jenkins: Sidebar-Link Plugin
    # Downloadable from:
    #   https://wiki.jenkins-ci.org/display/JENKINS/Sidebar-Link+Plugin
    # Direct link:
    #   http://updates.jenkins-ci.org/latest/sidebar-link.hpi
    jenkins_sidebar-link_plugin:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/jenkins
        item_base_name: sidebar-link.v1.7.hpi
        item_content_hash: md5=ff33db98be4d85726daf5ba46e6a4603
        plugin_name: sidebar-link

    # Nexus maven repository manager (community edition).
    # Downloadable from:
    #   http://www.sonatype.org/nexus/go/
    nexus_maven_repository_manager:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/nexus
        # Version 2.11.1-01: `nexus-2.11.1-01-bundle.tar.gz`
        item_base_name: nexus-2.11.1-01-bundle.tar.gz
        item_content_hash: md5=fec9d1b734089f8fae0e9755f2a1bc75
        nexus_bundle_version_infix: '2.11.1-01'

    # 7zip archiver.
    # 7-zip installer.
    # Downloadable from:
    #   http://www.7-zip.org/download.html
    7zip_64_bit_windows:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/7zip
        item_base_name: 7z920-x64.msi
        item_content_hash: md5=cac92727c33bec0a79965c61bbb1c82f

    # Pre-downloaded Cygwin package with required components.
    cygwin_package_64_bit_windows:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        installation_directory: 'C:\cygwin64'
        # Checking existance of this file confirms existing installation.
        completion_file_indicator: 'C:\cygwin64\installed.txt'
        item_parent_dir_path: common/cygwin
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

    # Oracle Java 1.7 JDK.
    # Link: http://www.oracle.com/technetwork/java/javase/downloads/index.html
    oracle_jdk-7u71-linux-x64.rpm:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/java
        item_base_name: jdk-7u71-linux-x64.rpm
        item_content_hash: md5=f9dafcc0bd52f085c8b0894c27b39d10

    # See:
    #   https://github.com/tmux-plugins/tmux-resurrect
    tmux_resurrect_plugin:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/tmux
        item_base_name: tmux-resurrect-2.4.0.tar.gz
        item_content_hash: md5=75db424eb50d36902ee9052e20458c67

    # OpenStack YUM repository config RPM package.
    # Downloadable from:
    #   https://repos.fedorapeople.org/repos/openstack/openstack-juno/
    openstack-rdo-release-juno-1.noarch.rpm:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/openstack
        item_base_name: rdo-release-juno-1.noarch.rpm
        item_content_hash: md5=ec6cb4b3d103bd57cde344df6f5759ac

###############################################################################
# EOF
###############################################################################

