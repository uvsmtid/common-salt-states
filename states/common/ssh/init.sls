# SSH server

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}


ssh_server:
    pkg.installed:
        - name: openssh-server
        - aggregate: True
    service.running:
        - name: sshd
        - enable: True
        - require:
            - pkg: ssh_server
        - watch:
            - file: /etc/ssh/sshd_config


/etc/ssh/sshd_config:
    file.managed:
        - source: salt://common/ssh/sshd_config
        - user: root
        - group: root
        - mode: 644
        - template: jinja

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

# OpenSSH server on Windows depends on Cygwin installation:

{% set system_secrets_macro_lib = 'common/system_secrets/lib.sls' %}
{% from system_secrets_macro_lib import get_single_line_system_secret with context %}

{% from 'common/libs/utils.lib.sls' import get_windows_salt_content_temp_dir_cygwin with context %}

{% set cygwin_settings = pillar['system_features']['cygwin_settings'] %}

{% if cygwin_settings['cygwin_installation_method'] %}

{% set cygwin_root_dir = cygwin_settings['installation_directory'] %}

include:
    - common.cygwin.package

{% set cygwin_ssh_service_setup_method = cygwin_settings['cygwin_ssh_service_setup_method'] %}

{% if cygwin_ssh_service_setup_method == 'user' %} # cygwin_ssh_service_setup_method

# TODO: At the moment the SSH server is not started automatically after
#       installation. It is only started after reboot.
#       There is a Windows command `tasklist` and `/var/run/sshd.pid` PID
#       file for SSH server which makes it possible to implement it later.

{% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}

# Run command to for first user login (to create home directory):
run_login_shell:
    cmd.run:
        - name: '{{ cygwin_root_dir }}\bin\bash.exe -l -c "echo test"'
        - require:
            - sls: common.cygwin.package

# Make sure directory exists:
'{{ cygwin_root_dir }}\home\{{ account_conf['username'] }}':
    file.exists:
        - require:
            - sls: common.cygwin.package
            - cmd: run_login_shell

# Provide SSH server configuration:
'{{ cygwin_root_dir }}\home\{{ account_conf['username'] }}\sshd\sshd_config':
    file.managed:
        - source: salt://common/ssh/sshd_config.cygwin
        - template: jinja
        - makedirs: true
        - require:
            - file: '{{ cygwin_root_dir }}\home\{{ account_conf['username'] }}'
            - sls: common.cygwin.package

# Provide SSH server start file per user:
'{{ account_conf['windows_user_home_dir'] }}\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\sshd_start.cmd':
    file.managed:
        - source: salt://common/ssh/sshd_start.cmd
        - template: jinja
        - require:
            - file: '{{ cygwin_root_dir }}\home\{{ account_conf['username'] }}\sshd\sshd_config'
            - sls: common.cygwin.package

{% elif cygwin_ssh_service_setup_method == 'service' %} # cygwin_ssh_service_setup_method

{% set primary_user = pillar['system_hosts'][grains['id']]['primary_user'] %}
{% set account_conf = pillar['system_accounts'][ primary_user ] %}
{% set CYGWIN_env_var_value = " ".join(cygwin_settings['CYGWIN_env_var_items_list']) %}

# Save user environment variables for inspection just in case.
save_environment_environment:
    cmd.run:
        - name: '{{ cygwin_root_dir }}\bin\bash.exe -l -c "env > {{ get_windows_salt_content_temp_dir_cygwin() }}/ssh.setup.env.txt"'
        - runas: {{ account_conf['username'] }}
        - password: {{ get_single_line_system_secret(account_conf['password_secret']) }}

cygwin_ssh_setup_service:
    cmd.run:
        # NOTE: We reuse password of primary user.
        # NOTE: We specify primary user to run `sshd` in option `--user`.
        #       Otherwise, setup does not work for some reasons and creates
        #       user named as `<machine_name>+cyg_server`.
        #       See: https://cygwin.com/ml/cygwin/2016-01/msg00016.html
        - name: {{ cygwin_root_dir }}\bin\bash.exe -l -c "ssh-host-config --yes --cygwin '{{ CYGWIN_env_var_value }}' --name sshd --user {{ account_conf['username'] }} --pwd {{ get_single_line_system_secret(account_conf['password_secret']) }}"
        # NOTE: Do not install SSH service if there is already one.
        - unless: '{{ cygwin_root_dir }}\bin\bash.exe -l -c "cygrunsrv -Q sshd"'
        - runas: {{ account_conf['username'] }}
        - password: {{ get_single_line_system_secret(account_conf['password_secret']) }}
        - require:
            - cmd: save_environment_environment

# Some permissions do not allow SSH service to start.
# See also permissions fixes for SSH by bootstrap script:
#    "states/bootstrap/bootstrap.ps1.sls"
fix_permission_var_empty:
    cmd.run:
        - name: 'chmod go-rw /var/empty'

cygwin_ssh_start_service:
    cmd.run:
        - name: '{{ cygwin_root_dir }}\bin\bash.exe -l -c "cygrunsrv -S sshd"'
        - require:
            - cmd: cygwin_ssh_setup_service
            - cmd: fix_permission_var_empty

{% endif %} # cygwin_ssh_service_setup_method

{% endif %}

{% endif %}
# >>>
###############################################################################


