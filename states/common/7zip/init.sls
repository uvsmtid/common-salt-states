# LEAVE THIS LINE TO ENABLE BASIC SYNTAX HIGHLIGHTING

# Set `config_temp_dir`:
{% if grains['kernel'] == 'Linux' %}
{% set config_temp_dir = pillar['posix_config_temp_dir'] %}
{% endif %}
{% if grains['kernel'] == 'Windows' %}
{% set config_temp_dir = pillar['windows_config_temp_dir'] %}
{% endif %}

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

# TODO: Rewrite to use `7zip_64_bit_windows` content item.

# 7-zip installation.
install_7zip_on_windows:
    cmd.run:
        - name: 'cmd /c {{ config_temp_dir }}\install_7zip_on_windows.bat'
        - unless: 'dir "C:\Program Files\7-Zip\7z.exe"'
        - require:
            - file: '{{ config_temp_dir }}\7z920-x64.msi'
            - file: '{{ config_temp_dir }}\install_7zip_on_windows.bat'

'{{ config_temp_dir }}\install_7zip_on_windows.bat':
    file.managed:
        - source: salt://common/7zip/install_7zip_on_windows.bat
        - template: jinja
        - makedirs: True

# Download file from depository_role.
'{{ config_temp_dir }}\7z920-x64.msi':
    file.managed:
        - source: http://depository_role/distrib/7zip/7z920-x64.msi
        - source_hash: md5=cac92727c33bec0a79965c61bbb1c82f
        - makedirs: True

{% endif %}
# >>>
###############################################################################


