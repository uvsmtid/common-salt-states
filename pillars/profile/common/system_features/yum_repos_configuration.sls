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
                        yum_repo_baseurl: 'http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'
                    rhel5:
                        yum_repo_baseurl: ''
                        yum_repo_key_url: ''

            # Default repositories with updates.
            updates:
                # Installation type:
                # - conf_template
                #       Configuration using template file.
                installation_type: conf_template

                os_platform_configs:
                    f21:
                        yum_repo_baseurl: 'http://download.fedoraproject.org/pub/fedora/linux/updates/$releasever/$basearch/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$releasever-$basearch'
                        # TODO
                        #manage_key: False
                        #yum_repo_resource_id:
                    rhel7:
                        yum_repo_baseurl: 'http://mirror.centos.org/centos/$releasever/updates/$basearch/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'
                    rhel5:
                        yum_repo_baseurl: ''
                        yum_repo_key_url: ''


            # EPEL repository for RHEL.
            epel:
                installation_type: conf_template

                os_platform_configs:
                    rhel7:
                        yum_repo_baseurl: 'http://download.fedoraproject.org/pub/epel/7/$basearch'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7'
                    rhel5:
                        yum_repo_baseurl: ''
                        yum_repo_key_url: ''

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

                os_platform_configs:
                    f21:
                        yum_repo_baseurl: 'http://pkg.jenkins-ci.org/redhat'
                        yum_repo_key_url: ~
                    rhel7:
                        yum_repo_baseurl: 'http://pkg.jenkins-ci.org/redhat'
                        yum_repo_key_url: ~



###############################################################################
# EOF
###############################################################################

