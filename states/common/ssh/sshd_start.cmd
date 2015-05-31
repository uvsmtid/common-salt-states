@echo on
REM This script starts OpenSSH daemon for Cygwin

{% set cygwin_root_dir = pillar['system_resources']['cygwin_package_64_bit_windows']['installation_directory'] %}

REM Cygwin root directory is hardcoded/fixed (it's a convention)
IF DEFINED PROGRAMFILES(x86) (
    echo "64 bit"
    set CYGWINSETUPEXE=setup-x86_64.exe
    set CYGWINROOTDIR={{ cygwin_root_dir }}
) ELSE (
    echo "32 bit"
    set CYGWINSETUPEXE=setup-x86.exe
    set CYGWINROOTDIR=%CYGWIN_DRIVE%:\cygwin32
    echo "32 bit is not supported"
    EXIT /B 1
)
echo CYGWINSETUPEXE=%CYGWINSETUPEXE%
echo CYGWINROOTDIR=%CYGWINROOTDIR%


REM Show hint for user.
echo Specified installation directory: "%CYGWINROOTDIR%"

REM Show IP configuration
ipconfig

REM Create key if it does not exists
{% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
"%CYGWINROOTDIR%\bin\bash.exe" -c "if [ ! -e /home/{{ account_conf['username'] }}/sshd/ssh_host_dsa_key ] ; then /usr/bin/ssh-keygen -q -N '' -t dsa -f /home/{{ account_conf['username'] }}/sshd/ssh_host_dsa_key; fi"
IF NOT %errorlevel%==0 (
    echo "Command returned: " %errorlevel%
    EXIT /B 1
)

REM Run OpenSSH
"%CYGWINROOTDIR%\bin\bash.exe" -c "/usr/sbin/sshd -f /home/{{ account_conf['username'] }}/sshd/sshd_config"
IF NOT %errorlevel%==0 (
    echo "Command returned: " %errorlevel%
    EXIT /B 1
)

