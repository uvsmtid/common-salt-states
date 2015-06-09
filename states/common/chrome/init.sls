# LEAVE THIS LINE TO ENABLE BASIC SYNTAX HIGHLIGHTING

{% if grains['kernel'] == 'Linux' %}
{% set config_temp_dir = pillar['posix_config_temp_dir'] %}
{% endif %}
{% if grains['kernel'] == 'Windows' %}
{% set config_temp_dir = pillar['windows_config_temp_dir'] %}
{% endif %}

# TODO: Rewrite to use `google_chrome_64_bit_windows` content item.

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}


# Chrome installation
install_chrome_on_windows:
    cmd.run:
        - name: 'cmd /c {{ config_temp_dir }}\install_chrome_on_windows.bat'
        - unless: 'dir "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"'
        - require:
            - file: '{{ config_temp_dir }}\ChromeStandaloneSetup.exe'
            - file: '{{ config_temp_dir }}\install_chrome_on_windows.bat'

'{{ config_temp_dir }}\install_chrome_on_windows.bat':
    file.managed:
        - source: salt://common/chrome/install_chrome_on_windows.bat
        - template: jinja

# Download file.
# TODO: Rewrite using macros to get resource files.
'{{ config_temp_dir }}\ChromeStandaloneSetup.exe':
    file.managed:
        - source: http://{{ pillar['system_host_roles']['depository_role']['hostname'] }}/distrib/chrome/ChromeStandaloneSetup.exe
        - source_hash: md5=b7427051a09887aee412911141497a9d

{% endif %}
# >>>
###############################################################################


