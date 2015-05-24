# LEAVE THIS LINE TO ENABLE BASIC SYNTAX HIGHLIGHTING

{% if grains['kernel'] == 'Linux' %}
{% set config_temp_dir = pillar['posix_config_temp_dir'] %}
{% endif %}
{% if grains['kernel'] == 'Windows' %}
{% set config_temp_dir = pillar['windows_config_temp_dir'] %}
{% endif %}

# TODO: Rewrite to use `python_2_7_64_bit_windows` content item.

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

python:
    pkg.installed:
        - name: python
        - aggregate: True

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}


# Python installation
# Install:
#start /wait msiexec /qn /i C:\Users\username\Desktop\python-2.7.6.amd64.msi
# Uninstall:
#start /wait msiexec /qn /x C:\Users\username\Desktop\python-2.7.6.amd64.msi
install_python_on_windows:
    cmd.run:
        - name: 'cmd /c {{ config_temp_dir }}\install_python_on_windows.bat'
        - unless: 'dir "C:\Python27\python.exe"'
        - require:
            - file: '{{ config_temp_dir }}\python-2.7.6.amd64.msi'
            - file: '{{ config_temp_dir }}\install_python_on_windows.bat'

'{{ config_temp_dir }}\install_python_on_windows.bat':
    file.managed:
        - source: salt://common/python/install_python_on_windows.bat
        - template: jinja

# Download file from depository_role
'{{ config_temp_dir }}\python-2.7.6.amd64.msi':
    file.managed:
        - source: http://depository_role/distrib/python/python-2.7.6.amd64.msi
        - source_hash: md5=b73f8753c76924bc7b75afaa6d304645

# Set PATH.
set_python_path:
    cmd.run:
        - name: 'echo %PATH% | findstr /I /C:";C:\Python27;" > nul || setx -m PATH "%PATH%;C:\Python27;"'
        - require:
            - cmd: install_python_on_windows

{% endif %}
# >>>
###############################################################################


