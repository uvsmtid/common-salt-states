from utils.exec_command import call_subprocess
from utils.set_accounts import add_user_to_group_windows
from utils.set_accounts import add_user_windows
#from utils.set_accounts import set_password

import logging

###############################################################################
#

def do(action_context):

    # NOTE: At the moment we don't create group for user on Windows.
    # TODO: Is it necessary?
    if False:
        add_group(
            group_name = action_context.conf_m.create_primary_user['primary_group'],
        )

    # Create user.
    add_user_windows(
        user_name = action_context.conf_m.create_primary_user['primary_user'],
        user_password = action_context.conf_m.create_primary_user['user_password']
    )

    # Add user to `administrators` group.
    add_user_to_group_windows(
        user_name = action_context.conf_m.create_primary_user['primary_user'],
        group_name = 'administrators',
    )

    # NOTE: Password for user in Windows is set during its creation.
    if False:
        if user_password:
            set_password(
                user_name = action_context.conf_m.create_primary_user['primary_user'],
                user_password = user_password,
            )

###############################################################################
# EOF
###############################################################################

