
import logging

from utils.install_salt import deploy_salt_windows
from utils.install_salt import delete_all_minion_keys_on_master

###############################################################################
#

def do(action_context):

    # NOTE: Salt master is not available for Windows.
    logging.warning("Ignore this step for Windows.")
    return

###############################################################################
# EOF
###############################################################################

