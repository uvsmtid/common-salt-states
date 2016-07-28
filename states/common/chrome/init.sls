# LEAVE THIS LINE TO ENABLE BASIC SYNTAX HIGHLIGHTING

{% from 'common/libs/utils.lib.sls' import get_salt_content_temp_dir with context %}

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
        - name: 'cmd /c {{ get_salt_content_temp_dir() }}\install_chrome_on_windows.bat'
        - unless: 'dir "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"'
        - require:
            - file: '{{ get_salt_content_temp_dir() }}\ChromeStandaloneSetup.exe'
            - file: '{{ get_salt_content_temp_dir() }}\install_chrome_on_windows.bat'

'{{ get_salt_content_temp_dir() }}\install_chrome_on_windows.bat':
    file.managed:
        - source: salt://common/chrome/install_chrome_on_windows.bat
        - template: jinja

# Download file.
# TODO: Rewrite using macros to get resource files.
'{{ get_salt_content_temp_dir() }}\ChromeStandaloneSetup.exe':
    file.managed:
        - source: http://{{ pillar['system_host_roles']['depository_role']['hostname'] }}/distrib/chrome/ChromeStandaloneSetup.exe
        - source_hash: md5=b7427051a09887aee412911141497a9d

{% endif %}
# >>>
###############################################################################


