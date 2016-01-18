
###############################################################################
#

system_features:

    static_bootstrap_configuration:

        # Location of directory with bootstrap relative to primary users' home.
        bootstrap_files_dir: 'bootstrap.dir'

        # TODO: It doesn't seem right that package type (archive type)
        #       depends on any platform. What if there are multiple
        #       platforms within a system, will there be multiple packages?
        #       The whole idea about bootstrap is to have single package
        #       per system instance.
        os_platform_package_types:
            fc21: tar.gz
            fc22: tar.gz
            fc23: tar.gz
            fc24: tar.gz
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
                    fc21:
                        salt-master:
                            source_type: tar
                            resource_id: salt-master_downloaded_rpms_with_dependencies_2014.7.1-1.fc21.x86_64
                    fc22:
                        salt-master:
                            source_type: tar
                            # NOTE: This RPM was created for `fc21` and simply reused here.
                            # TODO: Generate new resource for `fc22`.
                            resource_id: salt-master_downloaded_rpms_with_dependencies_2014.7.1-1.fc21.x86_64
                    fc23:
                        salt-master:
                            source_type: tar
                            # NOTE: This RPM was created for `fc21` and simply reused here.
                            # TODO: Generate new resource for `fc23`.
                            resource_id: salt-master_downloaded_rpms_with_dependencies_2014.7.1-1.fc21.x86_64
                    fc24:
                        salt-master:
                            source_type: tar
                            # NOTE: This RPM was created for `fc21` and simply reused here.
                            # TODO: Generate new resource for `fc24`.
                            resource_id: salt-master_downloaded_rpms_with_dependencies_2014.7.1-1.fc21.x86_64
                    rhel5:
                        salt:
                            source_type: tar
                            resource_id: salt_downloaded_rpms_with_dependencies_2015.5.3-4.el5.x86_64.tar
                        salt-master:
                            source_type: rpm
                            resource_id: salt-master-2015.5.3-4.noarch.el5.rpm
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
                    fc21:
                        salt-master:
                            source_type: tar
                            resource_id: salt-minion_downloaded_rpms_with_dependencies_2014.7.1-1.fc21.x86_64
                    fc22:
                        salt-master:
                            source_type: tar
                            # NOTE: This RPM was created for `fc21` and simply reused here.
                            # TODO: Generate new resource for `fc22`.
                            resource_id: salt-minion_downloaded_rpms_with_dependencies_2014.7.1-1.fc21.x86_64
                    fc23:
                        salt-master:
                            source_type: tar
                            # NOTE: This RPM was created for `fc21` and simply reused here.
                            # TODO: Generate new resource for `fc23`.
                            resource_id: salt-minion_downloaded_rpms_with_dependencies_2014.7.1-1.fc21.x86_64
                    fc24:
                        salt-master:
                            source_type: tar
                            # NOTE: This RPM was created for `fc21` and simply reused here.
                            # TODO: Generate new resource for `fc24`.
                            resource_id: salt-minion_downloaded_rpms_with_dependencies_2014.7.1-1.fc21.x86_64
                    rhel5:
                        salt:
                            source_type: tar
                            resource_id: salt_downloaded_rpms_with_dependencies_2015.5.3-4.el5.x86_64.tar
                        salt-minion:
                            source_type: rpm
                            resource_id: salt-minion-2015.5.3-4.noarch.el5.rpm
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

