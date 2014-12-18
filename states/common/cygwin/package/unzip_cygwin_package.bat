
{% if grains['kernel'] == 'Linux' %}
{% set config_temp_dir = pillar['posix_config_temp_dir'] %}
{% endif %}
{% if grains['kernel'] == 'Windows' %}
{% set config_temp_dir = pillar['windows_config_temp_dir'] %}
{% endif %}


REM Extract Cygwin package installer:
REM This command will create a sub-dicrecory called `cygwin.distrib` in the destination directory.

REM 32 bit
"C:\\Program Files\\7-Zip\\7z.exe" -y x "{{ config_temp_dir }}\\{{ pillar['registered_content_items']['cygwin_package_64_bit_windows']['item_base_name'] }}" -o"{{ config_temp_dir }}"


