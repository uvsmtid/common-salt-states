
###############################################################################
#

include:
    - {{ this_pillar }}.java_environments_configuration
    - {{ this_pillar }}.vagrant_configuration
    - {{ this_pillar }}.hostname_resolution_config
    - {{ this_pillar }}.maven_installation_configuration
    - {{ this_pillar }}.maven_repository_manager_configuration
    - {{ this_pillar }}.postgresql_environment_setup
    - {{ this_pillar }}.bash_prompt_info_config
    - {{ this_pillar }}.external_http_proxy
    - {{ this_pillar }}.offline_yum_repo
    - {{ this_pillar }}.allow_package_installation_through_yum
    - {{ this_pillar }}.configure_jenkins
    - {{ this_pillar }}.deploy_environment_sources
    - {{ this_pillar }}.resource_repositories_configuration
    - {{ this_pillar }}.source_symlinks_configuration
    - {{ this_pillar }}.deploy_central_control_directory
    - {{ this_pillar }}.set_kernel_vga_console_type_for_text_mode
    - {{ this_pillar }}.disable_boot_time_splash_screen
    - {{ this_pillar }}.source_version_control_tools_config
    - {{ this_pillar }}.assign_DISPLAY_environment_variable
    - {{ this_pillar }}.initialize_ssh_connections
    - {{ this_pillar }}.configure_sudo_for_specified_users
    - {{ this_pillar }}.validate_depository_role_content
    - {{ this_pillar }}.time_configuration
    - {{ this_pillar }}.tmux_features_configuration
    - {{ this_pillar }}.yum_repos_configuration

###############################################################################
# EOF
###############################################################################

