
###############################################################################

from utils.exec_command import call_subprocess

###############################################################################
#

def enable_service_systemd(
    service_name,
    raise_on_error = True,
):

    call_subprocess(
        command_args = [
            '/usr/bin/systemctl',
            'enable',
            service_name,
        ],
        raise_on_error = raise_on_error,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
#

def disable_service_systemd(
    service_name,
    raise_on_error = True,
):

    call_subprocess(
        command_args = [
            '/usr/bin/systemctl',
            'disable',
            service_name,
        ],
        raise_on_error = raise_on_error,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
#

def start_service_systemd(
    service_name,
    raise_on_error = True,
):

    call_subprocess(
        command_args = [
            '/usr/bin/systemctl',
            'start',
            service_name,
        ],
        raise_on_error = raise_on_error,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
#

def stop_service_systemd(
    service_name,
    raise_on_error = True,
):

    call_subprocess(
        command_args = [
            '/usr/bin/systemctl',
            'stop',
            service_name,
        ],
        raise_on_error = raise_on_error,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
#

def enable_service_initd(
    service_name,
    raise_on_error = True,
):

    call_subprocess(
        command_args = [
            '/sbin/chkconfig',
            service_name,
            'on',
        ],
        raise_on_error = raise_on_error,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
#

def disable_service_initd(
    service_name,
    raise_on_error = True,
):

    call_subprocess(
        command_args = [
            '/sbin/chkconfig',
            service_name,
            'off',
        ],
        raise_on_error = raise_on_error,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
#

def start_service_initd(
    service_name,
    raise_on_error = True,
):

    call_subprocess(
        command_args = [
            '/sbin/service',
            service_name,
            'start',
        ],
        raise_on_error = raise_on_error,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
#

def stop_service_initd(
    service_name,
    raise_on_error = True,
):

    call_subprocess(
        command_args = [
            '/sbin/service',
            service_name,
            'stop',
        ],
        raise_on_error = raise_on_error,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
#

def enable_service_powershell(
    service_name,
    raise_on_error = True,
):

    call_subprocess(
        command_args = [
            'powershell',
            'Set-Service',
            '-StartupType',
            'automatic',
            service_name,
        ],
        raise_on_error = raise_on_error,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
#

def disable_service_powershell(
    service_name,
    raise_on_error = True,
):

    call_subprocess(
        command_args = [
            'powershell',
            'Set-Service',
            '-StartupType',
            'manual',
            service_name,
        ],
        raise_on_error = raise_on_error,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
#

def start_service_powershell(
    service_name,
    raise_on_error = True,
):

    call_subprocess(
        command_args = [
            'powershell',
            'Start-Service',
            service_name,
        ],
        raise_on_error = raise_on_error,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
#

def stop_service_powershell(
    service_name,
    raise_on_error = True,
):

    call_subprocess(
        command_args = [
            'powershell',
            'Stop-Service',
            service_name,
        ],
        raise_on_error = raise_on_error,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
# EOF
###############################################################################

