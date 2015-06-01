import logging
from utils.exec_command import call_subprocess

###############################################################################
#

def add_group(
    group_name,
):

    # Check if group already exists.
    process_output = call_subprocess(
        command_args = [
            '/usr/bin/getent',
            'group',
            group_name,
        ],
        raise_on_error = False,
        capture_stdout = False,
        capture_stderr = False,
    )
    if process_output["code"] == 0:
        logging.warning("group '" + group_name + "' already exists")
        return
    elif process_output["code"] == 2:
        # One or more supplied key could not be found in the database.
        pass
    else:
        raise RuntimeError

    # Create group.
    call_subprocess(
        command_args = [
            '/usr/sbin/groupadd',
            group_name,
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

    # Verify.
    call_subprocess(
        command_args = [
            '/usr/bin/getent',
            'group',
            group_name,
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
#

def add_user(
    user_name,
    group_name,
):

    # Check if group already exists.
    process_output = call_subprocess(
        command_args = [
            '/usr/bin/getent',
            'passwd',
            user_name,
        ],
        raise_on_error = False,
        capture_stdout = False,
        capture_stderr = False,
    )
    if process_output["code"] == 0:
        logging.warning("user '" + user_name + "' already exists")
        return
    elif process_output["code"] == 2:
        # One or more supplied key could not be found in the database.
        pass
    else:
        raise RuntimeError

    # Create user.
    call_subprocess(
        command_args = [
            '/usr/sbin/useradd',
            user_name,
            '--gid',
            group_name,
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

    # Verify.
    call_subprocess(
        command_args = [
            '/usr/bin/getent',
            'passwd',
            user_name,
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
#

def set_password(
    user_name,
    user_password,
):

    logging.debug('user_password: ' + str(user_password))

    # Set `user_password` for specified user.
    process_output = call_subprocess(
        command_args = [
            '/usr/bin/passwd',
            '--stdin',
            user_name,
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
        cwd = None,
        stdin_string = user_password,
    )

###############################################################################
# EOF
###############################################################################

