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
# single host (i.e. `salt_master_role`) and execute `ssh-copy-id` to every other
# host.
#
# The last obstacle to solve is that first connection will prompt for password
# which requires interactive user response. In order to avoid it, `sshpass`
# utility is used:
#   http://stackoverflow.com/a/20748503/441652

{% from 'common/libs/utils.lib.sls' import get_salt_content_temp_dir with context %}

{% set system_secrets_macro_lib = 'common/system_secrets/lib.sls' %}
{% from system_secrets_macro_lib import get_single_line_system_secret with context %}

{% from 'common/libs/host_config_queries.sls' import is_network_checks_allowed with context %}

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel5') %}

# Even though `sshpass` may be installed on RHEL5, use `salt_master_role` with
# modern OS instead.

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel7') or grains['os_platform_type'].startswith('fc') %}

{% if grains['id'] in pillar['system_host_roles']['salt_master_role']['assigned_hosts'] %}

{% if pillar['system_features']['initialize_ssh_connections']['feature_enabled'] %}

package_sshpass:
    pkg.installed:
        - name: sshpass
        - aggregate: True

'{{ get_salt_content_temp_dir() }}/ssh/distribute_public_keys.sh':
    file.managed:
        - source: salt://common/ssh/distribute_public_keys.sh
        - template: jinja
        {% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
        - user: {{ account_conf['username'] }}
        - group: {{ account_conf['primary_group'] }}
        - mode: 544
        - makedirs: True

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
{% set account_conf = pillar['system_accounts'][ host_config['primary_user'] ] %}
{%
    set selected_account = {
        'hostname': host_config['hostname']
        ,
        'username': account_conf['username']
        ,
        'password_value': get_single_line_system_secret(account_conf['password_secret'])
    }
%}

{% set os_type = pillar['system_platforms'][host_config['os_platform']]['os_type'] %}

#------------------------------------------------------------------------------
# Distribute the key:
'{{ case_name }}_place_public_key_on_remote_account_{{ selected_role_name }}_{{ selected_account['hostname'] }}_cmd':
    cmd.run:
        - name: '{{ get_salt_content_temp_dir() }}/ssh/distribute_public_keys.sh "{{ selected_account['hostname'] }}" "{{ selected_account['username'] }}" "{{ os_type }}"'
        {% set local_account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
        - user: {{ local_account_conf['username'] }}
        # Pass `password_value` in environment variable (`SSHPASS` according to `sshpass` documentation).
        - env:
            - SSHPASS: '{{ selected_account['password_value'] }}'
        - require:
            - pkg: package_sshpass
            - file: '{{ get_salt_content_temp_dir() }}/ssh/distribute_public_keys.sh'
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

{% for account_conf in pillar['system_features']['initialize_ssh_connections']['extra_public_key_deployment_destinations']['hosts_by_host_role'][selected_role_name].values() %}

# Compose expected data object:
{% set
    selected_account = {
        'hostname': host_config['hostname']
        ,
        'username': account_conf['username']
        ,
        'password_value': get_single_line_system_secret(account_conf['password_secret'])
    }
%}
{% set os_type = pillar['system_platforms'][host_config['os_platform']]['os_type'] %}

#------------------------------------------------------------------------------
# Distribute the key:
'{{ case_name }}_place_public_key_on_remote_account_{{ selected_role_name }}_{{ selected_account['hostname'] }}_cmd':
    cmd.run:
        - name: '{{ get_salt_content_temp_dir() }}/ssh/distribute_public_keys.sh "{{ selected_account['hostname'] }}" "{{ selected_account['username'] }}" "{{ os_type }}"'
        {% set local_account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
        - user: {{ local_account_conf['username'] }}
        # Pass `password_value` in environment variable (`SSHPASS` according to `sshpass` documentation).
        - env:
            - SSHPASS: '{{ selected_account['password_value'] }}'
        - require:
            - pkg: package_sshpass
            - file: '{{ get_salt_content_temp_dir() }}/ssh/distribute_public_keys.sh'
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

{% if is_network_checks_allowed(None) == 'True' %}

{% for account_conf in pillar['system_features']['initialize_ssh_connections']['extra_public_key_deployment_destinations']['hosts_by_hostname'][hostname]['user_configs'].values() %}

# Compose expected data object:
{%
    set selected_account = {
        'hostname': hostname
        ,
        'username': account_conf['username']
        ,
        'password_value': get_single_line_system_secret(account_conf['password_secret'])
    }
%}
{% set os_type = pillar['system_platforms'][host_config['os_platform']]['os_type'] %}

#------------------------------------------------------------------------------
# Distribute the key:
'{{ case_name }}_place_public_key_on_remote_account_{{ selected_account['hostname'] }}_{{ selected_account['username'] }}_cmd':
    cmd.run:
        - name: '{{ get_salt_content_temp_dir() }}/ssh/distribute_public_keys.sh "{{ selected_account['hostname'] }}" "{{ selected_account['username'] }}" "{{ os_type }}"'
        {% set local_account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
        - user: {{ local_account_conf['username'] }}
        # Pass `password_value` in environment variable (`SSHPASS` according to `sshpass` documentation).
        - env:
            - SSHPASS: '{{ selected_account['password_value'] }}'
        - require:
            - pkg: package_sshpass
            - file: '{{ get_salt_content_temp_dir() }}/ssh/distribute_public_keys.sh'
#------------------------------------------------------------------------------

{% endfor %} # Inner loop of 5.

{% endif %} # online

{% endfor %} # Outter loop of 5.
# End of 5.




{% endif %}

{% endif %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

# Utility `sshpass` is currently not available on Cygwin.

{% endif %}
# >>>
###############################################################################

