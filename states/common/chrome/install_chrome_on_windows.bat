REM LEAVE THIS LINE TO ENABLE BASIC SYNTAX HIGHLIGHTING

{% if grains['kernel'] == 'Linux' %}
{% set config_temp_dir = pillar['posix_config_temp_dir'] %}
{% endif %}
{% if grains['kernel'] == 'Windows' %}
{% set config_temp_dir = pillar['windows_config_temp_dir'] %}
{% endif %}

REM TODO: Rewrite to use `google_chrome_64_bit_windows` content item.

REM Install Chrome:
"{{ config_temp_dir }}\ChromeStandaloneSetup.exe"


