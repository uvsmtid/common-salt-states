
{% if grains['kernel'] == 'Linux' %}
{% set config_temp_dir = pillar['posix_config_temp_dir'] %}
{% endif %}
{% if grains['kernel'] == 'Windows' %}
{% set config_temp_dir = pillar['windows_config_temp_dir'] %}
{% endif %}

REM TODO: Rewrite to use `7zip_64_bit_windows` content item.

start /wait msiexec /qr /i "{{ config_temp_dir }}\7z920-x64.msi"

REM TODO: Add 7zip to the PATH:


