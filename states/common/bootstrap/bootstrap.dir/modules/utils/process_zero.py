from utils.exec_command import call_subprocess

###############################################################################
#

def enable_service_systemd(
    service_name,
):

    call_subprocess(
        command_args = [
            '/usr/bin/systemctl',
            'enable',
            service_name,
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
#

def start_service_systemd(
    service_name,
):

    call_subprocess(
        command_args = [
            '/usr/bin/systemctl',
            'start',
            service_name,
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
#

def enable_service_initd(
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

def start_service_initd(
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
# EOF
###############################################################################

