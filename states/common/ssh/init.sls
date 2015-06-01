# SSH server

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}


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
{% if grains['os'] in [ 'Windows' ] %}

# OpenSSH server on Windows depends on Cygwin installation:

{% if pillar['system_resources']['cygwin_package_64_bit_windows']['enable_installation'] %}

{% set cygwin_root_dir = pillar['system_resources']['cygwin_package_64_bit_windows']['installation_directory'] %}

include:
    - common.cygwin.package

# TODO: At the moment the SSH server is not started automatically after
#       installation. It is only started after reboot.
#       There is a Windows command `tasklist` and `/var/run/sshd.pid` PID
#       file for SSH server which makes it possible to implement it later.

{% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}

# Provide SSH server start file per user:
'{{ account_conf['windows_user_home_dir'] }}\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\sshd_start.cmd':
    file.managed:
        - source: salt://common/ssh/sshd_start.cmd
        - template: jinja
        - require:
            - file: '{{ cygwin_root_dir }}\home\{{ account_conf['username'] }}\sshd\sshd_config'
            - sls: common.cygwin.package

# Provide SSH server configuration:
'{{ cygwin_root_dir }}\home\{{ account_conf['username'] }}\sshd\sshd_config':
    file.managed:
        - source: salt://common/ssh/sshd_config.cygwin
        - template: jinja
        - makedirs: true
        - require:
            - file: '{{ cygwin_root_dir }}\home\{{ account_conf['username'] }}'
            - sls: common.cygwin.package

# Make sure directory exists:
'{{ cygwin_root_dir }}\home\{{ account_conf['username'] }}':
    file.exists:
        - require:
            - sls: common.cygwin.package
            - cmd: run_login_shell

# Run command to for first user login (to create home directory):
run_login_shell:
    cmd.run:
        - name: '{{ cygwin_root_dir }}\bin\bash.exe -l -c "echo test"'
        - require:
            - sls: common.cygwin.package

{% endif %}

{% endif %}
# >>>
###############################################################################


