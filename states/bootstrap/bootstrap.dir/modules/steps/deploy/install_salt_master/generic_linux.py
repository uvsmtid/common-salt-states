from utils.install_salt import deploy_salt
from utils.install_salt import delete_all_minion_keys_on_master

###############################################################################
#

def do(action_context):

    # Call comon function for salt installation.
    deploy_salt(
        temp_rpm_dir_path_rel = 'rpms',
        salt_deploy_step_config = action_context.conf_m.install_salt_master,
        action_context = action_context,
    )

    # Delete all minion keys.
    delete_all_minion_keys_on_master()

###############################################################################
# EOF
###############################################################################

