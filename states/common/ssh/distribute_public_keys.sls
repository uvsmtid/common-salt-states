# This state distributes public keys to every primary user (to remote
# `~/.ssh/authorized_keys` file) on each minion to enable passwordless
# authentication.
#
# If public key is put on remote host to `~/.ssh/authorized_keys`, any future
# connection from any host which can present corresponding private key will
# be successful (no username/hostname matching is done for greater security).
#
# The approach which enables all primary users to connect to each
# other on any host relies on this fact. All we need is to connect from a
# single host (i.e. `controller_role`) and execute `ssh-copy-id` to every other
# host.
#
# The last obstacle to solve is that first connection will prompt for password
# which requires interactive user response. In order to avoid it, `sshpass`
# utility is used:
#   http://stackoverflow.com/a/20748503/441652

{% if grains['kernel'] == 'Linux' %}
{% set config_temp_dir = pillar['posix_config_temp_dir'] %}
{% endif %}
{% if grains['kernel'] == 'Windows' %}
{% set config_temp_dir = pillar['windows_config_temp_dir'] %}
{% endif %}

{% from 'common/libs/host_config_queries.sls' import is_network_checks_allowed with context %}

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS' ] %}

# Even though `sshpass` may be installed on RHEL5, use `controller_role` with
# modern OS instead.

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Fedora' ] %}

{% if grains['id'] in pillar['system_host_roles']['controller_role']['assigned_hosts'] %}

{% if pillar['system_features']['initialize_ssh_connections']['feature_enabled'] %}

package_sshpass:
    pkg.installed:
        - name: sshpass
        - aggregate: True

'{{ config_temp_dir }}/ssh/distribute_public_keys.sh':
    file.managed:
        - source: salt://common/ssh/distribute_public_keys.sh
        - template: jinja
        - user: {{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}
        - group: {{ pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}
        - mode: 544

# Loop through all defined hosts and execute `ssh-copy-id` to them.
# Password is provided.

# TODO: It's code duplication due to poor Python logic/loop support in Jinja templates:
#       https://groups.google.com/forum/#!topic/salt-users/gUNUEFWds1U
#
# 1. Use all defined hosts:
{% set case_name = 'all_defined_hosts' %}

{% set selected_role_name = 'none' %}

{% set all_defined_host_ids = pillar['system_hosts'].keys() %}

{% for host_id in all_defined_host_ids %}

{% set host_config = pillar['system_hosts'][host_id] %}

{% if is_network_checks_allowed(host_id) == 'True' %}

# Compose expected data object:
{% set selected_account = { 'hostname': host_config['hostname'], 'username': host_config['primary_user']['username'], 'password': host_config['primary_user']['password'] } %}

#------------------------------------------------------------------------------
# Distribute the key:
'{{ case_name }}_place_public_key_on_remote_account_{{ selected_role_name }}_{{ selected_account['hostname'] }}_cmd':
    cmd.run:
        - name: '{{ config_temp_dir }}/ssh/distribute_public_keys.sh "{{ selected_account['hostname'] }}" "{{ selected_account['username'] }}" "{{ host_config['os_type'] }}"'
        - user: {{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}
        # Pass password in environment variable (`SSHPASS` according to `sshpass` documentation).
        - env:
            - SSHPASS: '{{ selected_account['password'] }}'
        - require:
            - pkg: package_sshpass
            - file: '{{ config_temp_dir }}/ssh/distribute_public_keys.sh'
#------------------------------------------------------------------------------

{% endif %}

{% endfor %} # Outter loop of 1.
# End of 1.


# TODO: It's code duplication due to poor Python logic/loop support in Jinja templates:
#       https://groups.google.com/forum/#!topic/salt-users/gUNUEFWds1U
#
# 2. All hosts roles specified for public key deployment:
{% set case_name = 'all_required_host_roles' %}

{% for selected_role_name in pillar['system_features']['initialize_ssh_connections']['extra_public_key_deployment_destinations']['hosts_by_host_role'].keys() %}

{% for minion_id in pillar['system_host_roles'][selected_role_name]['assigned_hosts'] %}

{% set host_config = pillar['system_hosts'][minion_id] %}

{% if is_network_checks_allowed(minion_id) == 'True' %}

{% for user_config in pillar['system_features']['initialize_ssh_connections']['extra_public_key_deployment_destinations']['hosts_by_host_role'][selected_role_name].values() %}

# Compose expected data object:
{% set selected_account = { 'hostname': host_config['hostname'], 'username': user_config['username'], 'password': user_config['password'] } %}

#------------------------------------------------------------------------------
# Distribute the key:
'{{ case_name }}_place_public_key_on_remote_account_{{ selected_role_name }}_{{ selected_account['hostname'] }}_cmd':
    cmd.run:
        - name: '{{ config_temp_dir }}/ssh/distribute_public_keys.sh "{{ selected_account['hostname'] }}" "{{ selected_account['username'] }}" "{{ host_config['os_type'] }}"'
        - user: {{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}
        # Pass password in environment variable (`SSHPASS` according to `sshpass` documentation).
        - env:
            - SSHPASS: '{{ selected_account['password'] }}'
        - require:
            - pkg: package_sshpass
            - file: '{{ config_temp_dir }}/ssh/distribute_public_keys.sh'
#------------------------------------------------------------------------------

{% endfor %} # Inner loop of 2.

{% endif %}

{% endfor %}

{% endfor %} # Outter loop of 2.
# End of 2.


# TODO: It's code duplication due to poor Python logic/loop support in Jinja templates:
#       https://groups.google.com/forum/#!topic/salt-users/gUNUEFWds1U
#
# 5. All hostnames specified for public key deployment:
{% set case_name = 'all_required_hosthostnames' %}

{% for hostname in pillar['system_features']['initialize_ssh_connections']['extra_public_key_deployment_destinations']['hosts_by_hostname'].keys() %}

{% set host_config = pillar['system_features']['initialize_ssh_connections']['extra_public_key_deployment_destinations']['hosts_by_hostname'][hostname] %}

{% for user_config in pillar['system_features']['initialize_ssh_connections']['extra_public_key_deployment_destinations']['hosts_by_hostname'][hostname]['user_configs'].values() %}

# Compose expected data object:
{% set selected_account = { 'hostname': hostname, 'username': user_config['username'], 'password': user_config['password'] } %}

#------------------------------------------------------------------------------
# Distribute the key:
'{{ case_name }}_place_public_key_on_remote_account_{{ selected_account['hostname'] }}_{{ selected_account['username'] }}_cmd':
    cmd.run:
        - name: '{{ config_temp_dir }}/ssh/distribute_public_keys.sh "{{ selected_account['hostname'] }}" "{{ selected_account['username'] }}" "{{ host_config['os_type'] }}"'
        - user: {{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}
        # Pass password in environment variable (`SSHPASS` according to `sshpass` documentation).
        - env:
            - SSHPASS: '{{ selected_account['password'] }}'
        - require:
            - pkg: package_sshpass
            - file: '{{ config_temp_dir }}/ssh/distribute_public_keys.sh'
#------------------------------------------------------------------------------

{% endfor %} # Inner loop of 5.

{% endfor %} # Outter loop of 5.
# End of 5.




{% endif %}

{% endif %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

# Utility `sshpass` is currently not available on Cygwin.

{% endif %}
# >>>
###############################################################################

