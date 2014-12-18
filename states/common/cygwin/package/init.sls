# This installs Cygwin using pre-downloaded zip package file.

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

{% if pillar['registered_content_items']['cygwin_package_64_bit_windows']['enable_installation'] %}

{% set cygwin_root_dir = pillar['registered_content_items']['cygwin_package_64_bit_windows']['installation_directory'] %}
{% set cygwin_installation_completion_file_indicator = pillar['registered_content_items']['cygwin_package_64_bit_windows']['completion_file_indicator'] %}

include:

# Run cygwin installation:
install_cygwin_package:
    cmd.run:
        - name: 'cmd /c {{ config_temp_dir }}\cygwin.distrib\repo\installer\install_cygwin.cmd'
        - unless: 'dir {{ cygwin_installation_completion_file_indicator }}'
        - require:
            - file: '{{ config_temp_dir }}\cygwin.distrib\repo\installer\install_cygwin.cmd'
            - cmd: unzip_cygwin_package

# Patch cygwin installer script:
'{{ config_temp_dir }}\cygwin.distrib\repo\installer\install_cygwin.cmd':
    file.managed:
        - source: salt://common/cygwin/package/install_cygwin.cmd
        - template: jinja
        - makedirs: True
        - require:
            - cmd: unzip_cygwin_package

# Unzip cygwin package:
unzip_cygwin_package:
    cmd.run:
        - name: 'cmd /c {{ config_temp_dir }}\unzip_cygwin_package.bat'
        - unless: 'cd {{ config_temp_dir }}\cygwin.distrib'
        - require:
            - file: '{{ config_temp_dir }}\{{ pillar['registered_content_items']['cygwin_package_64_bit_windows']['item_base_name'] }}'
            - file: '{{ config_temp_dir }}\unzip_cygwin_package.bat'

# Set CYGWIN environment variable.
# According to Cygwin:
#   http://cygwin.com/cygwin-ug-net/using-cygwinenv.html
#   "It contains the options listed below, separated by blank characters."
{% set CYGWIN_env_var_value = " ".join(pillar['registered_content_items']['cygwin_package_64_bit_windows']['CYGWIN_env_var_items_list']) %}
set_CYGWIN_env_var_value:
    cmd.run:
        - name: 'setx -m CYGWIN "{{ CYGWIN_env_var_value }}"'

# Script to unzip the package:
'{{ config_temp_dir }}\unzip_cygwin_package.bat':
    file.managed:
        - source: salt://common/cygwin/package/unzip_cygwin_package.bat
        - makedirs: True
        - template: jinja

# Archive:
'{{ config_temp_dir }}\{{ pillar['registered_content_items']['cygwin_package_64_bit_windows']['item_base_name'] }}':
    file.managed:
        - source: http://depository_role/{{ pillar['registered_content_items']['cygwin_package_64_bit_windows']['item_parent_dir_path'] }}/{{ pillar['registered_content_items']['cygwin_package_64_bit_windows']['item_base_name'] }}
        - source_hash: {{ pillar['registered_content_items']['cygwin_package_64_bit_windows']['item_content_hash'] }}
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
{% set cygwin_bin_path = pillar['registered_content_items']['cygwin_package_64_bit_windows']['installation_directory'] + '\\bin' %}
add_cygwin_bin_path_to_PATH:
    cmd.run:
        - name: 'echo %PATH% | findstr /I /C:";{{ cygwin_bin_path }};" > nul || setx -m PATH "%PATH%;{{ cygwin_bin_path }};"'
        - require:
            - cmd: install_cygwin_package

{% endif %}

{% endif %}
# >>>
###############################################################################


