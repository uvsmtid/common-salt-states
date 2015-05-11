###############################################################################
#

system_features:

    yum_repos_configuration:

        feature_enabled: True

        yum_repositories:

            fedora:
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

            base:
                installation_type: conf_template

                os_platform_configs:
                    rhel5:
                        yum_repo_baseurl: ''
                        yum_repo_key_url:
                    rhel7:
                        yum_repo_baseurl:
                        yum_repo_key_url:

            epel:
                installation_type: conf_template

                os_platform_configs:
                    rhel5:
                        yum_repo_baseurl: ''
                        yum_repo_key_url:
                    rhel7:
                        yum_repo_baseurl:
                        yum_repo_key_url:

            postgresql:
                installation_type: conf_template

                os_platform_configs:
                    rhel5:
                        yum_repo_baseurl: ''
                        yum_repo_key_url:
                    rhel7:
                        yum_repo_baseurl:
                        yum_repo_key_url:

###############################################################################
# EOF
###############################################################################

