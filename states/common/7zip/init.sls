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

{% if pillar['registered_content_items']['7zip_64_bit_windows']['enable_installation'] %}

{% set URI_prefix = pillar['registered_content_config']['URI_prefix'] %}

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
'{{ config_temp_dir }}/{{ pillar['registered_content_items']['7zip_64_bit_windows']['item_base_name'] }}':
    file.managed:
        - source: "{{ URI_prefix }}/{{ pillar['registered_content_items']['7zip_64_bit_windows']['item_parent_dir_path'] }}/{{ pillar['registered_content_items']['7zip_64_bit_windows']['item_base_name'] }}"
        - source_hash: {{ pillar['registered_content_items']['7zip_64_bit_windows']['item_content_hash'] }}
        - makedirs: True

{% endif %} # enable_installation

{% endif %}
# >>>
###############################################################################


