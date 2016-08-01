
{% from 'common/libs/utils.lib.sls' import get_salt_content_temp_dir with context %}

REM TODO: Rewrite to use `7zip_64_bit_windows` content item.

start /wait msiexec /qr /i "{{ get_salt_content_temp_dir() }}\7z920-x64.msi"

REM TODO: Add 7zip to the PATH:


