
###############################################################################
#

include:

{% for sub_item in [
        'java_environments_configuration'
        ,
        'vagrant_configuration'
        ,
        'hostname_resolution_config'
        ,
        'maven_installation_configuration'
        ,
        'maven_repository_manager_configuration'
        ,
        'postgresql_environment_setup'
        ,
        'bash_prompt_info_config'
        ,
        'external_http_proxy'
        ,
        'allow_package_installation_through_yum'
        ,
        'configure_jenkins'
        ,
        'jenkins_generated_bootstrap'
        ,
        'deploy_environment_sources'
        ,
        'resource_repositories_configuration'
        ,
        'source_symlinks_configuration'
        ,
        'deploy_central_control_directory'
        ,
        'set_kernel_vga_console_type_for_text_mode'
        ,
        'disable_boot_time_splash_screen'
        ,
        'source_version_control_tools_config'
        ,
        'assign_DISPLAY_environment_variable'
        ,
        'initialize_ssh_connections'
        ,
        'configure_sudo_for_specified_users'
        ,
        'validate_depository_role_content'
        ,
        'time_configuration'
        ,
        'tmux_features_configuration'
        ,
        'yum_repos_configuration'
        ,
        'custom_root_CA_certificates'
        ,
        'smtp_connection_settings'
        ,
        'packages_per_os_platfrom_type'
        ,
        'email_notifications_lists'
        ,
        'configure_sonarqube'
        ,
        'sonarqube_quality_gates'
        ,
        'wildfly_deployments'
        ,
        'enable_primary_user_auto_login'
    ]
%}
    - {{ this_pillar }}.{{ sub_item }}:
        defaults:
            this_pillar: {{ this_pillar }}.{{ sub_item }}
            profile_root: {{ profile_root }}

{% endfor %}

###############################################################################
# EOF
###############################################################################

