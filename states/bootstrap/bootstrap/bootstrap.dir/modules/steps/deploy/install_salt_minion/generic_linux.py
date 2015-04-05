from utils.install_salt import deploy_salt

###############################################################################
#

def do(action_context):

    # Set version of Salt minion config.
    if action_context.run_use_case in [
        'offline-minion-installer',
    ]:
        action_context.conf_m.install_salt_minion['src_salt_config_file'] = action_context.conf_m.install_salt_minion['src_salt_offline_config_file']
    else:
        action_context.conf_m.install_salt_minion['src_salt_config_file'] = action_context.conf_m.install_salt_minion['src_salt_online_config_file']

    # Call comon function for salt installation.
    deploy_salt(
        temp_rpm_dir_path_rel = 'rpms',
        salt_deploy_step_config = action_context.conf_m.install_salt_minion,
        action_context = action_context,
    )

###############################################################################
# EOF
###############################################################################

