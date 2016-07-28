
{% from 'common/libs/utils.lib.sls' import get_salt_content_temp_dir with context %}

REM Extract Cygwin package installer:
REM This command will create a sub-dicrecory called `cygwin.distrib` in the destination directory.

REM 32 bit
"C:\\Program Files\\7-Zip\\7z.exe" -y x "{{ get_salt_content_temp_dir() }}\\{{ pillar['system_resources']['cygwin_package_64_bit_windows']['item_base_name'] }}" -o"{{ get_salt_content_temp_dir() }}"


