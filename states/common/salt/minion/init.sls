# Configure Salt minion

# WARNING: This configuration is for the minion, but it will not be effective
#          because minion process is already running while this configuration
#          is applied. It should not go to the top file, instead, it should
#          be applied via `salt-call` before starting the minion.
#          Anyway it is documented requirement and can be used for validation.

###############################################################################
# <<< Any RedHat-originated OS
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

install_salt_minion:
    pkg.installed:
        - name: salt-minion
    service.running:
        - name: salt-minion
        - enable: True
# No mananaging of Salt configuration.
# TODO: Validation states for Salt configuration are still OK to add.
# All configuration is inside /etc/salt/minion to be consistent with Windows.
#        - require:
#            - file: /etc/salt/minion_id

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<< Windows
{% if grains['os'] in [ 'Windows' ] %}

# File to start Salt minion per user.
'{{ pillar['system_hosts'][grains['id']]['primary_user']['windows_user_home_dir'] }}\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\run_salt_minion.bat':
    file.managed:
        # NOTE: Paths for Windows in state tree are provided in Cygwin notation.
        # This is to avoid messing with drive letters.
        - source: 'salt://common/salt/minion/run_salt_minion.bat'
        - template: jinja

# Add Salt installation dir to PATH.
{% set installation_dir = pillar['registered_content_items']['salt_minion_64_bit_windows']['installation_dir'] %}
add_salt_minion_tools_to_PATH:
    cmd.run:
        - name: 'echo %PATH% | findstr /I /C:";{{ installation_dir }};" > nul || setx -m PATH "%PATH%;{{ installation_dir }};"'

{% endif %}
# >>> Windows
###############################################################################



