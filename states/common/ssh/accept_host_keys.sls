# This state accepts SSH host keys from each host defined on the system.

# WARNING: Execute this state after public authentication is already set up.
#          Otherwise, it is not clear why `ssh` fails: because of failed
#          connection in general or because of authentication problem.
#          Basically, this sate assumes authentication is alright.

# NOTE: This state may seem useless if public authentication is already
#       set up (in this case connection to remote hosts may already be
#       performed and the host in the `known_hosts` file anyway).
#       The state is still required - it is executed on every minion to
#       make every system host known to it.
#
#       On the other hand, the public authentication is set up using single
#       host - this works because only single pair of public/private keys is
#       used (so that any other host which uses the same keys will work
#       regardless which host first set them up). This state runs from
#       all hosts.

{% from 'common/libs/utils.lib.sls' import get_salt_content_temp_dir with context %}

{% from 'common/libs/host_config_queries.sls' import is_network_checks_allowed with context %}

{% from 'common/libs/utils.lib.sls' import get_windows_salt_content_temp_dir_cygwin with context %}

{% if pillar['system_features']['initialize_ssh_connections']['feature_enabled'] %}

{% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

include:
    - common.ssh

'accept_host_keys_script_deploy':
    file.managed:
        - name: '{{ get_salt_content_temp_dir() }}/ssh/accept_host_keys.sh'
        - source: salt://common/ssh/accept_host_keys.sh
        - template: jinja
        - user: {{ account_conf['username'] }}
        - group: {{ account_conf['primary_group'] }}
        - mode: 544
        - makedirs: True
        - require:
            - sls: common.ssh

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

include:
    - common.ssh

{% set cygwin_settings = pillar['system_features']['cygwin_settings'] %}

{% set cygwin_root_dir = cygwin_settings['installation_directory'] %}

{% set system_secrets_macro_lib = 'common/system_secrets/lib.sls' %}
{% from system_secrets_macro_lib import get_single_line_system_secret with context %}

unlock_accept_host_keys_script_permissions:
    cmd.run:
        - name: '{{ cygwin_root_dir }}\bin\bash.exe -l -c "if [ -f {{ get_windows_salt_content_temp_dir_cygwin() }}/ssh/accept_host_keys.sh ] ; then chmod 777 {{ get_windows_salt_content_temp_dir_cygwin() }}/ssh/accept_host_keys.sh ; fi"'
        # NOTE: Option `runas` is not supported before `2016.3.0`.
        #       It used to be `user` instead.
        - runas: {{ account_conf['username'] }}
        - password: {{ get_single_line_system_secret(account_conf['password_secret']) }}

'accept_host_keys_script_deploy':
    file.managed:
        - name: '{{ get_salt_content_temp_dir() }}\ssh\accept_host_keys.sh'
        - source: salt://common/ssh/accept_host_keys.sh
        - template: jinja
        - makedirs: True
        - require:
            - sls: common.ssh
            - cmd: unlock_accept_host_keys_script_permissions

'accept_host_keys_script_dos2unix':
    cmd.run:
        # The `--force` option is requred because `dos2unix` may identify some
        # characters as binary and skips conversion of the file.
        - name: '{{ cygwin_root_dir }}\bin\dos2unix.exe --force "{{ get_salt_content_temp_dir() }}\ssh\accept_host_keys.sh"'
        - require:
            - file: 'accept_host_keys_script_deploy'

'accept_host_keys_script_permissions':
    cmd.run:
        - name: '{{ cygwin_root_dir }}\bin\chmod 555 "{{ get_salt_content_temp_dir() }}\ssh\accept_host_keys.sh"'
        - require:
            - file: 'accept_host_keys_script_deploy'

{% endif %}
# >>>
###############################################################################



# TODO: It's code duplication due to poor Python logic/loop support in Jinja templates:
#       https://groups.google.com/forum/#!topic/salt-users/gUNUEFWds1U
#
# 1. Primary users.
{% set case_name = 'all_defined_hosts' %}

{% set selected_role_name = 'none' %}

{% for host_id in pillar['system_hosts'].keys() %}

{% set host_config = pillar['system_hosts'][host_id] %}

{% if is_network_checks_allowed(host_id) == 'True' %} # online

# Compose expected data object:
{% set account_conf = pillar['system_accounts'][ host_config['primary_user'] ] %}
{%
    set selected_host = {
        'hostname': host_config['hostname']
        ,
        'username': account_conf['username']
        ,
        'password_secret': account_conf['password_secret']
    }
%}

#------------------------------------------------------------------------------

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

'{{ case_name }}_{{ selected_role_name }}_{{ selected_host['hostname'] }}_accept_ssh_key_cmd':
    cmd.run:
        - name: '{{ get_salt_content_temp_dir() }}/ssh/accept_host_keys.sh "{{ selected_host['hostname'] }}" "{{ selected_host['username'] }}"'
        {% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
        - user: '{{ account_conf['username'] }}'
        - require:
            - sls: common.ssh
            - file: 'accept_host_keys_script_deploy'

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

'{{ case_name }}_{{ selected_role_name }}_{{ selected_host['hostname'] }}_accept_ssh_key_cmd':
    cmd.run:
        # The script file potentially does not have execute permissions.
        # Execute through bash-interpreter.
        - name: '{{ cygwin_root_dir }}\bin\bash.exe -l "{{ get_windows_salt_content_temp_dir_cygwin() }}/ssh/accept_host_keys.sh" "{{ selected_host['hostname'] }}" "{{ selected_host['username'] }}"'
        - require:
            - sls: common.ssh
            - file: 'accept_host_keys_script_deploy'
            - cmd: 'accept_host_keys_script_dos2unix'

{% endif %}
# >>>
###############################################################################

#------------------------------------------------------------------------------

{% endif %} # online

{% endfor %} # Outter loop of 1.
# End of 1.


# TODO: It's code duplication due to poor Python logic/loop support in Jinja templates:
#       https://groups.google.com/forum/#!topic/salt-users/gUNUEFWds1U
#
# 2. All required roles.
{% set case_name = 'all_required_roles' %}

{% for selected_role_name in pillar['system_features']['initialize_ssh_connections']['extra_public_key_deployment_destinations']['hosts_by_host_role'].keys() %}

{% for minion_id in pillar['system_host_roles'][selected_role_name]['assigned_hosts'] %}

{% set host_config = pillar['system_hosts'][minion_id] %}

{% if is_network_checks_allowed(minion_id) == 'True' %} # online

{% for user_config in pillar['system_features']['initialize_ssh_connections']['extra_public_key_deployment_destinations']['hosts_by_host_role'][selected_role_name].values() %}

# Compose expected data object:
{%
    set selected_host = {
        'hostname': host_config['hostname']
        ,
        'username': user_config['username']
        ,
        'password_secret': user_config['password_secret']
    }
%}

#------------------------------------------------------------------------------

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

'{{ case_name }}_{{ selected_role_name }}_{{ selected_host['hostname'] }}_accept_ssh_key_cmd':
    cmd.run:
        - name: '{{ get_salt_content_temp_dir() }}/ssh/accept_host_keys.sh "{{ selected_host['hostname'] }}" "{{ selected_host['username'] }}"'
        {% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
        - user: '{{ account_conf['username'] }}'
        - require:
            - sls: common.ssh
            - file: 'accept_host_keys_script_deploy'

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

'{{ case_name }}_{{ selected_role_name }}_{{ selected_host['hostname'] }}_accept_ssh_key_cmd':
    cmd.run:
        # The script file potentially does not have execute permissions.
        # Execute through bash-interpreter.
        - name: '{{ cygwin_root_dir }}\bin\bash.exe -l "{{ get_windows_salt_content_temp_dir_cygwin() }}/ssh/accept_host_keys.sh" "{{ selected_host['hostname'] }}" "{{ selected_host['username'] }}"'
        - require:
            - sls: common.ssh
            - file: 'accept_host_keys_script_deploy'
            - cmd: 'accept_host_keys_script_dos2unix'

{% endif %}
# >>>
###############################################################################

#------------------------------------------------------------------------------

{% endfor %} # Inner loop of 2.

{% endif %} # online

{% endfor %} # `minion_id`

{% endfor %} # Outer loop of 2.
# End of 2.


# TODO: It's code duplication due to poor Python logic/loop support in Jinja templates:
#       https://groups.google.com/forum/#!topic/salt-users/gUNUEFWds1U
#
# 5. All required hostnames.
{% set case_name = 'all_required_hosthostnames' %}

{% for hostname in pillar['system_features']['initialize_ssh_connections']['extra_public_key_deployment_destinations']['hosts_by_hostname'].keys() %}

{% set host_config = pillar['system_features']['initialize_ssh_connections']['extra_public_key_deployment_destinations']['hosts_by_hostname'][hostname] %}

{% if is_network_checks_allowed(None) == 'True' %} # online

{% for user_config in pillar['system_features']['initialize_ssh_connections']['extra_public_key_deployment_destinations']['hosts_by_hostname'][hostname]['user_configs'].values() %}

# Compose expected data object:
{%
    set selected_host = {
        'hostname': hostname
        ,
        'username': user_config['username']
        ,
        'password_secret': user_config['password_secret']
    }
%}

#------------------------------------------------------------------------------

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

'{{ case_name }}_{{ hostname }}_{{ selected_host['username'] }}_accept_ssh_key_cmd':
    cmd.run:
        - name: '{{ get_salt_content_temp_dir() }}/ssh/accept_host_keys.sh "{{ selected_host['hostname'] }}" "{{ selected_host['username'] }}"'
        {% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
        - user: '{{ account_conf['username'] }}'
        - require:
            - sls: common.ssh
            - file: 'accept_host_keys_script_deploy'

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

'{{ case_name }}_{{ hostname }}_{{ selected_host['username'] }}_accept_ssh_key_cmd':
    cmd.run:
        # The script file potentially does not have execute permissions.
        # Execute through bash-interpreter.
        - name: '{{ cygwin_root_dir }}\bin\bash.exe -l "{{ get_windows_salt_content_temp_dir_cygwin() }}/ssh/accept_host_keys.sh" "{{ selected_host['hostname'] }}" "{{ selected_host['username'] }}"'
        - require:
            - sls: common.ssh
            - file: 'accept_host_keys_script_deploy'
            - cmd: 'accept_host_keys_script_dos2unix'

{% endif %}
# >>>
###############################################################################

#------------------------------------------------------------------------------

{% endfor %} # Inner loop of 5.

{% endif %} # online

{% endfor %} # Outer loop of 5.
# End of 5.




{% endif %} # Feature.


