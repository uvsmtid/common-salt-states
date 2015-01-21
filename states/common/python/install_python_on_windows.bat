
{% if grains['kernel'] == 'Linux' %}
{% set config_temp_dir = pillar['posix_config_temp_dir'] %}
{% endif %}
{% if grains['kernel'] == 'Windows' %}
{% set config_temp_dir = pillar['windows_config_temp_dir'] %}
{% endif %}

REM TODO: Rewrite to use `python_2_7_64_bit_windows` content item.

REM Install:
REM start /wait msiexec /qn /i C:\Users\username\Desktop\python-2.7.6.amd64.msi
REM Uninstall:
REM start /wait msiexec /qn /x C:\Users\username\Desktop\python-2.7.6.amd64.msi

REM Install Python:
start /wait msiexec /qr /i "{{ config_temp_dir }}\python-2.7.6.amd64.msi"

REM TODO: Add Python to the PATH:


