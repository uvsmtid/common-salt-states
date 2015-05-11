
###############################################################################
#

{% set master_minion_id = salt['config.get']('this_system_keys:master_minion_id') %}
{% set profile = salt['config.get']('this_system_keys:profile') %}

system_features:

    bootstrap_configuration:

        # Location of directory with bootstrap relative to primary users' home.
        bootstrap_files_dir: 'bootstrap.dir'

        enable_bootstrap_target_envs:
            {{ profile }}:

        # The very initial sources (symlinks) to make Salt operational.
        # NOTE: These are only `states` and `pillars`. Even though there can
        #       be more than one repo for `states, only the common one
        #       is specified (which bootstraps the rest).
        bootstrap_sources:
            states: common-salt-states
            pillars: common-salt-pillars

        bootstrap_package_use_cases:
            - 'initial-online-node'
            - 'offline-minion-installer'

        # Repositories which actually get exported.
        export_sources:
            common-salt-states:
                export_enabled: True
                export_method: clone
                export_format: dir
                branch_name: master
            common-salt-pillars:
                export_enabled: True
                export_method: clone
                export_format: dir
                branch_name: master

        generate_packages: False

        target_master_minion_id: {{ master_minion_id }}

        os_platform_package_types:
            rhel5: tar.gz
            rhel7: tar.gz
            f21: tar.gz
            win7: zip

        deploy_steps_params:
            init_ip_route:
                step_enabled: True
            init_dns_server:
                step_enabled: True
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
                yum_repo_configs:
                    rhel5:
                        #{# `pgdg` repo disabled for now - it may be configured through Salt, not bootstrap.
                        base:
                            installation_type: file
                            repo_config_template_file: 'salt://'
                            rpm_key_file_resource_id: ~
                        #}
                        epel:
                            installation_type: ~ # TODO: rpm
                            rpm_key_file_resource_id: epel5_yum_repository_rpm_verification_key
                        #{# `pgdg` repo disabled for now - it may be configured through Salt, not bootstrap.
                        pgdg:
                            installation_type: rpm
                            rpm_key_file_resource_id: epel5_yum_repository_rpm_verification_key
                        #}
                    rhel7:
                        epel:
                            installation_type: ~ # TODO: rpm
                            rpm_key_file_resource_id: epel7_yum_repository_rpm_verification_key
                    # TODO: remove this This is required because of pre-existing licesens.
                    f20:
                        base:
                            installation_type: ~
                    f21: {} # TODO
                    win7: {} # TODO
            install_salt_master:
                step_enabled: True
                salt_master_template: 'salt://common/salt/master/master.conf'
                salt_master_rpm_sources:
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
                    # TODO: remove this This is required because of pre-existing licesens.
                    f20:
                        base:
                            source_type: ~
                    f21: {} # TODO
                    win7: {} # TODO
            install_salt_minion:
                step_enabled: True
                salt_minion_online_template: 'salt://common/salt/minion/minion.online.conf'
                salt_minion_offline_template: 'salt://common/salt/minion/minion.offline.conf'
                salt_minion_rpm_sources:
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
                    # TODO: remove this This is required because of pre-existing licesens.
                    f20:
                        whatever:
                            source_type: ~
                    f21: {} # TODO
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

