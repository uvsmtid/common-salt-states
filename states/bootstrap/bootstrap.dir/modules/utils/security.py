
###############################################################################

from utils.exec_command import call_subprocess

###############################################################################
#

def turn_off_uac_windows(
):

    # See "Turn off UAC":
    #   https://github.com/uvsmtid/vagrant-boxes/blob/develop/windows-server-2012-R2-gui/readme.md

    call_subprocess(
        command_args = [
            'reg',
            'add',
            'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system',
            '/v',
            'EnableLUA',
            '/d',
            '0',
            '/t',
            'REG_DWORD',
            '/f',
            '/reg:64',
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
#

def disable_password_complexity_windows(
):

    # See "Disable complex passwords":
    #   https://github.com/uvsmtid/vagrant-boxes/blob/develop/windows-server-2012-R2-gui/readme.md

    call_subprocess(
        command_args = [
            'secedit',
            '/export',
            '/cfg',
            'c:\secpol.cfg',
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

    call_subprocess(
        command_args = [
            'powershell',
            '(gc C:\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\secpol.cfg',
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

    call_subprocess(
        command_args = [
            'secedit',
            '/configure',
            '/db',
            'c:\windows\security\local.sdb',
            '/cfg',
            'c:\secpol.cfg',
            '/areas',
            'SECURITYPOLICY',
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

    call_subprocess(
        command_args = [
            'powershell',
            'rm -force c:\secpol.cfg -confirm:$false',
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
#

def disable_shutdown_tracker_windows(
):

    # See "Disable Shutdown Tracker":
    #   https://github.com/uvsmtid/vagrant-boxes/blob/develop/windows-server-2012-R2-gui/readme.md

    call_subprocess(
        command_args = [
            'reg',
            'add',
            'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Policies\Microsoft\Windows NT\Reliability',
            '/v',
            'ShutdownReasonOn',
            '/d',
            '0',
            '/t',
            'REG_DWORD',
            '/f',
            '/reg:64',
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
#

def disable_server_manager_windows(
):

    # See "Disable Shutdown Tracker":
    #   https://github.com/uvsmtid/vagrant-boxes/blob/develop/windows-server-2012-R2-gui/readme.md

    call_subprocess(
        command_args = [
            'reg',
            'add',
            'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager',
            '/v',
            'DoNotOpenServerManagerAtLogon',
            '/d',
            '1',
            '/t',
            'REG_DWORD',
            '/f',
            '/reg:64',
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
# EOF
###############################################################################

