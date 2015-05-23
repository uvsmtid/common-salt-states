
###############################################################################
#

system_features:

    static_bootstrap_configuration:

        # Location of directory with bootstrap relative to primary users' home.
        bootstrap_files_dir: 'bootstrap.dir'

        os_platform_package_types:
            f21: tar.gz
            rhel5: tar.gz
            rhel7: tar.gz
            win7: zip

        deploy_steps_params:
            init_ip_route:
                step_enabled: True
            init_dns_server:
                step_enabled: True
                # TODO: Both `resolv.external.dns.conf` and `resolv.conf`
                #       files are identical after moving DNS settings into
                #       `hostname_resolution_config`. Leave only one.
                resolv_conf_template: 'salt://common/resolver/resolv.external.dns.conf'
            make_salt_resolvable:
                step_enabled: True
            set_hostname:
                step_enabled: True
            create_primary_user:
                step_enabled: True
            init_yum_repos:
                step_enabled: True
                yum_main_config_template: 'salt://common/yum/yum.conf'
                platform_repos_list_template: 'salt://common/yum/platform_repos_list.repo'
                # YUM configuration is based on data under
                # `yum_repos_configuration` key in pillars.
            install_salt_master:
                step_enabled: True
                salt_master_template: 'salt://common/salt/master/master.conf'
                salt_master_rpm_sources:
                    f21:
                        salt-master:
                            source_type: tar
                            resource_id: salt-master_downloaded_rpms_with_dependencies_2014.7.1-1.fc21.x86_64
                    rhel5:
                        salt-master:
                            source_type: zip
                            resource_id: salt-master_downloaded_rpms_with_dependencies_2014.7.1-1.el5.x86_64
                        python26-distribute:
                            source_type: zip
                            resource_id: python26-distribute_downloaded_rpms_with_dependencies_0.6.10-4.el5.x86_64
                        PyYAML:
                            source_type: tar
                            resource_id: PyYAML-3.09-10.el5.x86_64.rpms.tar
                    rhel7:
                        salt-master:
                            source_type: tar
                            resource_id: salt-master_downloaded_rpms_with_dependencies_2014.7.1-1.el7.x86_64
                        unzip:
                            source_type: rpm
                            resource_id: zip-3.0-10.el7.x86_64.rpm
                        zip:
                            source_type: rpm
                            resource_id: unzip-6.0-13.el7.x86_64.rpm
                        PyYAML:
                            source_type: tar
                            resource_id: PyYAML-3.10-11.el7.x86_64.rpms.tar
                    win7: {} # TODO
            install_salt_minion:
                step_enabled: True
                salt_minion_online_template: 'salt://common/salt/minion/minion.online.conf'
                salt_minion_offline_template: 'salt://common/salt/minion/minion.offline.conf'
                salt_minion_rpm_sources:
                    f21:
                        salt-master:
                            source_type: tar
                            resource_id: salt-minion_downloaded_rpms_with_dependencies_2014.7.1-1.fc21.x86_64
                    rhel5:
                        salt-minion:
                            source_type: zip
                            resource_id: salt-minion_downloaded_rpms_with_dependencies_2014.7.1-1.el5.x86_64
                        python26-distribute:
                            source_type: zip
                            resource_id: python26-distribute_downloaded_rpms_with_dependencies_0.6.10-4.el5.x86_64
                        PyYAML:
                            source_type: tar
                            resource_id: PyYAML-3.09-10.el5.x86_64.rpms.tar
                    rhel7:
                        salt-minion:
                            source_type: tar
                            resource_id: salt-minion_downloaded_rpms_with_dependencies_2014.7.1-1.el7.x86_64
                        unzip:
                            source_type: rpm
                            resource_id: zip-3.0-10.el7.x86_64.rpm
                        zip:
                            source_type: rpm
                            resource_id: unzip-6.0-13.el7.x86_64.rpm
                        PyYAML:
                            source_type: tar
                            resource_id: PyYAML-3.10-11.el7.x86_64.rpms.tar
                    win7: {} # TODO
            link_sources:
                step_enabled: True
            link_resources:
                step_enabled: True
            activate_salt_master:
                step_enabled: True
            activate_salt_minion:
                step_enabled: True
            run_init_states:
                step_enabled: True
            run_highstate:
                step_enabled: True

###############################################################################
# EOF
###############################################################################

