###############################################################################
#

system_features:

    yum_repos_configuration:

        feature_enabled: True

        yum_repositories:

            # Default OS repositories.
            base:
                # Installation type:
                # - conf_template
                #       Configuration using template file.
                installation_type: conf_template

                os_platform_configs:
                    f21:
                        yum_repo_baseurl: 'http://download.fedoraproject.org/pub/fedora/linux/releases/$releasever/Everything/$basearch/os/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$releasever-$basearch'
                        # TODO
                        #manage_key: False
                        #yum_repo_resource_id:
                    rhel7:
                        yum_repo_baseurl: 'http://mirror.centos.org/centos/$releasever/os/$basearch/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'
                    rhel5:
                        yum_repo_baseurl: 'http://mirror.centos.org/centos/$releasever/os/$basearch/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5'

            # Default repositories with updates.
            updates:
                installation_type: conf_template

                os_platform_configs:
                    f21:
                        yum_repo_baseurl: 'http://download.fedoraproject.org/pub/fedora/linux/updates/$releasever/$basearch/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$releasever-$basearch'
                    rhel7:
                        yum_repo_baseurl: 'http://mirror.centos.org/centos/$releasever/updates/$basearch/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'
                    rhel5:
                        yum_repo_baseurl: 'http://mirror.centos.org/centos/$releasever/updates/$basearch/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5'

            # EPEL repository for RHEL.
            epel:
                installation_type: conf_template

                os_platform_configs:
                    rhel7:
                        yum_repo_baseurl: 'http://download.fedoraproject.org/pub/epel/7/$basearch'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7'

                        # TODO: Add key file deployment into specific path.
                        key_file_resource_id: epel7_yum_repository_rpm_verification_key

                    rhel5:
                        yum_repo_baseurl: 'http://download.fedoraproject.org/pub/epel/5/$basearch'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL'

                        # TODO: Add key file deployment into specific path.
                        key_file_resource_id: epel5_yum_repository_rpm_verification_key

            # PostgreSQL 9.3.
            # See list of available repositories:
            #   http://yum.postgresql.org/repopackages.php
            postgresql:
                installation_type: conf_template

                os_platform_configs:
                    rhel5:
                        yum_repo_baseurl: 'http://yum.postgresql.org/9.3/redhat/rhel-$releasever-$basearch'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG-93'

            # Repository for OpenStack command line utils.
            # URL for installation RPM:
            #   https://repos.fedorapeople.org/repos/openstack/openstack-juno/rdo-release-juno-1.noarch.rpm
            openstack-juno:
                installation_type: conf_template

                os_platform_configs:
                    f21:
                        yum_repo_baseurl: 'https://repos.fedorapeople.org/repos/openstack/openstack-juno/fedora-$releasever/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-RDO-Juno'
                    rhel7:
                        yum_repo_baseurl: 'http://repos.fedorapeople.org/repos/openstack/openstack-juno/epel-7/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-RDO-Juno'

            # Jenkins.
            # See installation instructions:
            #   http://pkg.jenkins-ci.org/redhat/
            # Installation RPM: jenkins
            jenkins:
                installation_type: conf_template

                # NOTE: This repository could probably be used on rhel5
                #       as well. There is just one problem - key cannot be
                #       imported in default state.
                #       See: http://dan.carley.co/blog/2012/05/22/yum-gpg-keys-for-jenkins/

                os_platform_configs:
                    f21:
                        yum_repo_baseurl: 'http://pkg.jenkins-ci.org/redhat'
                        yum_repo_key_url: 'http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key'
                    rhel7:
                        yum_repo_baseurl: 'http://pkg.jenkins-ci.org/redhat'
                        yum_repo_key_url: 'http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key'

###############################################################################
# EOF
###############################################################################

