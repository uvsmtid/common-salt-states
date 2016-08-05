#

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel7') or grains['os_platform_type'].startswith('fc') %}

{% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
{% set user_home_dir = account_conf['posix_user_home_dir'] %}
{% set bootstrap_files_dir = pillar['system_features']['static_bootstrap_configuration']['bootstrap_files_dir'] %}
{% set bootstrap_dir = user_home_dir + '/' + bootstrap_files_dir %}

# Create initial bootstrap directory with sources.
bootstrap_directory_copy:
    file.recurse:
        - name: '{{ bootstrap_dir }}'
        - source: 'salt://bootstrap/bootstrap.dir'
        - makedirs: True
        - user: '{{ account_conf['username'] }}'
        - group: '{{ account_conf['primary_group'] }}'
        - file_mode: 644
        - dir_mode: 755
        - include_empty: True
        - recurse:
            - user
            - group
            - mode

bootstrap_file_powershell_script:
    file.managed:
        - name: '{{ bootstrap_dir }}/bootstrap.ps1'
        - source: 'salt://bootstrap/bootstrap.ps1.sls'
        - template: jinja
        - makedirs: True
        - user: '{{ account_conf['username'] }}'
        - group: '{{ account_conf['primary_group'] }}'
        - mode: 755
        - require:
            - file: bootstrap_directory_copy

bootstrap_file_linux_run_script:
    file.managed:
        - name: '{{ bootstrap_dir }}/run_bootstrap.sh'
        - source: 'salt://bootstrap/bootstrap.dir/run_bootstrap.sh.sls'
        - template: jinja
        - makedirs: True
        - user: '{{ account_conf['username'] }}'
        - group: '{{ account_conf['primary_group'] }}'
        - mode: 755
        - require:
            - file: bootstrap_directory_copy

bootstrap_file_windows_run_script:
    file.managed:
        - name: '{{ bootstrap_dir }}/run_bootstrap.cmd'
        - source: 'salt://bootstrap/bootstrap.dir/run_bootstrap.cmd.sls'
        - template: jinja
        - makedirs: True
        - user: '{{ account_conf['username'] }}'
        - group: '{{ account_conf['primary_group'] }}'
        - mode: 755
        - require:
            - file: bootstrap_directory_copy

# Because permissions are not replicated in the copy from master, we have
# to set executable permission on the main script.
# See:
#   https://github.com/saltstack/salt/issues/4423

bootstrap_file_exec_perms:
    file.managed:
        - name: '{{ bootstrap_dir }}/bootstrap.py'
        - source: 'salt://bootstrap/bootstrap.dir/bootstrap.py'
        - makedirs: True
        - user: '{{ account_conf['username'] }}'
        - group: '{{ account_conf['primary_group'] }}'
        - mode: 755
        - require:
            - file: bootstrap_directory_copy

{% endif %}
# >>>
###############################################################################

