
###############################################################################

import logging

from utils.security import turn_off_uac_windows
from utils.security import disable_password_complexity_windows
from utils.security import disable_shutdown_tracker_windows
from utils.security import disable_server_manager_windows

###############################################################################
#

def do(action_context):

    turn_off_uac_windows()

    disable_password_complexity_windows()

    disable_shutdown_tracker_windows()

    disable_server_manager_windows()

###############################################################################
# EOF
###############################################################################

