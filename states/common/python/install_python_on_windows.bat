
{% from 'common/libs/utils.lib.sls' import get_salt_content_temp_dir with context %}

REM TODO: Rewrite to use `python_2_7_64_bit_windows` content item.

REM Install:
REM start /wait msiexec /qn /i C:\Users\username\Desktop\python-2.7.6.amd64.msi
REM Uninstall:
REM start /wait msiexec /qn /x C:\Users\username\Desktop\python-2.7.6.amd64.msi

REM Install Python:
start /wait msiexec /qr /i "{{ get_salt_content_temp_dir() }}\python-2.7.6.amd64.msi"

REM TODO: Add Python to the PATH:


