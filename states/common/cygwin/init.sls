# LEAVE THIS LINE TO ENABLE BASIC SYNTAX HIGHLIGHTING

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

# DISABLED: This is disabled because it requires a lengthy download.
#           Providing local mirror for Cygwin costs (tested) about 15GB of
#           storage. Internet download is impossible in environments with
#           no connectivity. And even if Internet access is available,
#           it is potentially affected by changes in the Cygwin repository,
#           for example, installer, package names or something else may not
#           be compartible anymore.
#           See `common.cygwin.package` state instead.
{% if False %}

# Cygwin installation
install_cygwin_on_windows:
    cmd.run:
        - name: "cmd /c {{ config_temp_dir }}\install_cygwin_on_windows.bat"
        #- unless: 'dir TODO'
        - require:
            - file: "C:\cygwin.distrib\installer\setup-x86_64.exe"
            - file: "{{ config_temp_dir }}\install_cygwin_on_windows.bat"

"{{ config_temp_dir }}\install_cygwin_on_windows.bat":
    file.managed:
        - source: salt://common/cygwin/install_cygwin_on_windows.bat
        - template: jinja

# Download file from depository_role
"C:\cygwin.distrib\installer\setup-x86_64.exe":
    file.managed:
        - makedirs: True
        - source: http://depository_role/distrib/cygwin/setup-x86_64.exe
        - source_hash: md5=93ee19b4143133ec0d9462a27e5c92cb

{% endif %}

{% endif %}
# >>>
###############################################################################


