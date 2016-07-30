from utils.install_salt import deploy_salt_rhel
from utils.install_salt import delete_all_minion_keys_on_master

###############################################################################
#

def do(action_context):

    # Call comon function for salt installation.
    salt_deploy_step_config = action_context.conf_m.install_salt_master
    deploy_salt_rhel(
        temp_rpm_dir_path_rel = 'rpms',
        salt_deploy_step_config = salt_deploy_step_config,
        action_context = action_context,
    )

    # Skip keys removal if this host
    # is not supposed to be Salt master.
    # Deployment config only for Salt master has key `is_master`.
    if 'is_master' in salt_deploy_step_config:
        if not salt_deploy_step_config['is_master']:
            return

    # Delete all minion keys.
    delete_all_minion_keys_on_master()

###############################################################################
# EOF
###############################################################################

