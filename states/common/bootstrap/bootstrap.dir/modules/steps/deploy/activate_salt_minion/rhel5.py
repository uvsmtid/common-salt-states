import os
from utils.exec_command import call_subprocess

###############################################################################
#

def enable_service(
    service_name,
):

    call_subprocess(
        command_args = [
            '/sbin/chkconfig',
            service_name,
            'on',
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
#

def start_service(
    service_name,
):

    call_subprocess(
        command_args = [
            '/sbin/service',
            service_name,
            'start',
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
#

def do(action_context):

    enable_service(action_context.conf_m.activate_salt_minion['service_name'])
    start_service(action_context.conf_m.activate_salt_minion['service_name'])

###############################################################################
# EOF
###############################################################################


