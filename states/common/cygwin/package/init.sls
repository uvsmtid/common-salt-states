# This installs Cygwin using pre-downloaded zip package file.

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

{% if pillar['system_resources']['cygwin_package_64_bit_windows']['enable_installation'] %}

{% set cygwin_root_dir = pillar['system_resources']['cygwin_package_64_bit_windows']['installation_directory'] %}
{% set cygwin_installation_completion_file_indicator = pillar['system_resources']['cygwin_package_64_bit_windows']['completion_file_indicator'] %}

include:
    - common.7zip

# Run cygwin installation:
install_cygwin_package:
    cmd.run:
        - name: 'cmd /c {{ get_salt_content_temp_dir() }}\cygwin.distrib\repo\installer\install_cygwin.cmd'
        - unless: 'dir {{ cygwin_installation_completion_file_indicator }}'
        - require:
            - file: '{{ get_salt_content_temp_dir() }}\cygwin.distrib\repo\installer\install_cygwin.cmd'
            - cmd: unzip_cygwin_package

# Patch cygwin installer script:
'{{ get_salt_content_temp_dir() }}\cygwin.distrib\repo\installer\install_cygwin.cmd':
    file.managed:
        - source: 'salt://common/cygwin/package/install_cygwin.cmd'
        - template: jinja
        - makedirs: True
        - require:
            - cmd: unzip_cygwin_package

# Unzip cygwin package:
unzip_cygwin_package:
    cmd.run:
        - name: 'cmd /c {{ get_salt_content_temp_dir() }}\unzip_cygwin_package.bat'
        - unless: 'cd {{ get_salt_content_temp_dir() }}\cygwin.distrib'
        - require:
            - file: '{{ get_salt_content_temp_dir() }}\{{ pillar['system_resources']['cygwin_package_64_bit_windows']['item_base_name'] }}'
            - file: '{{ get_salt_content_temp_dir() }}\unzip_cygwin_package.bat'

# Set CYGWIN environment variable.
# According to Cygwin:
#   http://cygwin.com/cygwin-ug-net/using-cygwinenv.html
#   "It contains the options listed below, separated by blank characters."
{% set CYGWIN_env_var_value = " ".join(pillar['system_resources']['cygwin_package_64_bit_windows']['CYGWIN_env_var_items_list']) %}
set_CYGWIN_env_var_value:
    cmd.run:
        - name: 'setx -m CYGWIN "{{ CYGWIN_env_var_value }}"'

# Script to unzip the package:
'{{ get_salt_content_temp_dir() }}\unzip_cygwin_package.bat':
    file.managed:
        - source: 'salt://common/cygwin/package/unzip_cygwin_package.bat'
        - makedirs: True
        - template: jinja

{% set resources_macro_lib = 'common/resource_symlinks/resources_macro_lib.sls' %}
{% from resources_macro_lib import get_registered_content_item_URI with context %}
{% from resources_macro_lib import get_registered_content_item_hash with context %}

# Archive:
'{{ get_salt_content_temp_dir() }}\{{ pillar['system_resources']['cygwin_package_64_bit_windows']['item_base_name'] }}':
    file.managed:
        - source: {{ get_registered_content_item_URI('cygwin_package_64_bit_windows') }}
        - source_hash: {{ get_registered_content_item_hash('cygwin_package_64_bit_windows') }}
        - makedirs: True

# Create installation indicator:
'create_{{ cygwin_installation_completion_file_indicator }}':
    file.managed:
        - name: '{{ cygwin_installation_completion_file_indicator }}'
        - contents: "This indicates for Salt automation that Cygwin installation completed."
        - require:
            - cmd: install_cygwin_package

# NOTE: Double backward slashes `\\` is somehow required here.
#       Otherwise `\v` becomes a special character and PATH is not set.
{% set cygwin_bin_path = pillar['system_resources']['cygwin_package_64_bit_windows']['installation_directory'] + '\\bin' %}
add_cygwin_bin_path_to_PATH:
    cmd.run:
        - name: 'echo %PATH% | findstr /I /C:";{{ cygwin_bin_path }};" > nul || setx -m PATH "%PATH%;{{ cygwin_bin_path }};"'
        - require:
            - cmd: install_cygwin_package

{% endif %}

{% endif %}
# >>>
###############################################################################


