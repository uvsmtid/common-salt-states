# LEAVE THIS LINE TO ENABLE BASIC SYNTAX HIGHLIGHTING

{% from 'common/libs/utils.lib.sls' import get_salt_content_temp_dir with context %}

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

{% if pillar['system_resources']['7zip_64_bit_windows']['enable_installation'] %}

# 7-zip installation.
install_7zip_on_windows:
    cmd.run:
        - name: 'cmd /c {{ get_salt_content_temp_dir() }}\install_7zip_on_windows.bat'
        - unless: 'dir "C:\Program Files\7-Zip\7z.exe"'
        - require:
            - file: '{{ get_salt_content_temp_dir() }}\7z920-x64.msi'
            - file: '{{ get_salt_content_temp_dir() }}\install_7zip_on_windows.bat'

'{{ get_salt_content_temp_dir() }}\install_7zip_on_windows.bat':
    file.managed:
        - source: salt://common/7zip/install_7zip_on_windows.bat
        - template: jinja
        - makedirs: True

{% set resources_macro_lib = 'common/resource_symlinks/resources_macro_lib.sls' %}
{% from resources_macro_lib import get_registered_content_item_URI with context %}
{% from resources_macro_lib import get_registered_content_item_hash with context %}

# Download file.
'{{ get_salt_content_temp_dir() }}/{{ pillar['system_resources']['7zip_64_bit_windows']['item_base_name'] }}':
    file.managed:
        - source: {{ get_registered_content_item_URI('7zip_64_bit_windows') }}
        - source_hash: {{ get_registered_content_item_hash('7zip_64_bit_windows') }}
        - makedirs: True

{% endif %} # enable_installation

{% endif %}
# >>>
###############################################################################


