
import logging
from utils.install_salt import deploy_salt_windows

###############################################################################
#

def do(action_context):

    # Set version of Salt minion config.
    if action_context.run_use_case in [
        'offline-minion-installer',
    ]:

        # TODO: Offline Salt minions (without Salt master) are
        #       not supported on Windows yet.
        raise NotImplementedError

        action_context.conf_m.install_salt_minion['src_salt_config_file'] = action_context.conf_m.install_salt_minion['src_salt_offline_config_file']
    else:
        action_context.conf_m.install_salt_minion['src_salt_config_file'] = action_context.conf_m.install_salt_minion['src_salt_online_config_file']

    # Call comon function for salt installation.
    deploy_salt_windows(
        temp_rpm_dir_path_rel = 'rpms',
        salt_deploy_step_config = action_context.conf_m.install_salt_minion,
        action_context = action_context,
    )

###############################################################################
# EOF
###############################################################################

