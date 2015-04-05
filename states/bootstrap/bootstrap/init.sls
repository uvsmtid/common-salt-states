#

###############################################################################
# <<<
{% if grains['os'] in [ 'Fedora' ] %}

{% set user_home_dir = pillar['system_hosts'][grains['id']]['primary_user']['posix_user_home_dir'] %}
{% set bootstrap_files_dir = pillar['system_features']['bootstrap_configuration']['bootstrap_files_dir'] %}
{% set bootstrap_dir = user_home_dir + '/' + bootstrap_files_dir %}

# Create initial bootstrap directory with sources.
bootstrap_directory_copy:
    file.recurse:
        - name: '{{ bootstrap_dir }}'
        - source: 'salt://bootstrap/bootstrap/bootstrap.dir'
        - makedirs: True
        - user: '{{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}'
        - file_mode: 644
        - dir_mode: 755
        - include_empty: True
        - recurse:
            - user
            - group
            - mode

# Because permissions are not replicated in the copy from master, we have
# to set executable permission on the main script.
# See:
#   https://github.com/saltstack/salt/issues/4423

bootstrap_file_exec_perms:
    file.managed:
        - name: '{{ bootstrap_dir }}/bootstrap.py'
        - source: 'salt://bootstrap/bootstrap/bootstrap.dir/bootstrap.py'
        - makedirs: True
        - user: '{{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}'
        - mode: 755
        - require:
            - file: bootstrap_directory_copy

{% endif %}
# >>>
###############################################################################

