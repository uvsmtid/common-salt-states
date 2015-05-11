from utils.exec_command import call_subprocess
from utils.set_accounts import add_group
from utils.set_accounts import add_user

###############################################################################
#

def do(action_context):

    # Note that there is no intention to add password for this user.
    # The only reason why this user is created is to put sources under
    # its home directory.
    add_group(
        group_name = action_context.conf_m.create_primary_user['primary_group'],
    )

    add_user(
        user_name = action_context.conf_m.create_primary_user['primary_user'],
        group_name = action_context.conf_m.create_primary_user['primary_group'],
    )

###############################################################################
# EOF
###############################################################################

