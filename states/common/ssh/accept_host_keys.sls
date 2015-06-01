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

{% if grains['kernel'] == 'Linux' %}
{% set config_temp_dir = pillar['posix_config_temp_dir'] %}
{% endif %}
{% if grains['kernel'] == 'Windows' %}
{% set config_temp_dir = pillar['windows_config_temp_dir'] %}
{% endif %}

{% from 'common/libs/host_config_queries.sls' import is_network_checks_allowed with context %}

{% if pillar['system_features']['initialize_ssh_connections']['feature_enabled'] %}

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

include:
    - common.ssh

'{{ config_temp_dir }}/ssh/accept_host_keys.sh':
    file.managed:
        - source: salt://common/ssh/accept_host_keys.sh
        - template: jinja
        {% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
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
{% if grains['os'] in [ 'Windows' ] %}

include:
    - common.ssh

{% set cygwin_root_dir = pillar['system_resources']['cygwin_package_64_bit_windows']['installation_directory'] %}

'{{ config_temp_dir }}\accept_host_keys.sh':
    file.managed:
        - source: salt://common/ssh/accept_host_keys.sh
        - template: jinja
        - makedirs: True
        - require:
            - sls: common.ssh

'accept_host_keys_script_dos2unix':
    cmd.run:
        # The `--force` option is requred because `dos2unix` may identify some
        # characters as binary and skips conversion of the file.
        - name: '{{ cygwin_root_dir }}\bin\dos2unix.exe --force "{{ pillar['windows_config_temp_dir_cygwin'] }}/accept_host_keys.sh"'
        - require:
            - file: '{{ config_temp_dir }}\accept_host_keys.sh'

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

{% if is_network_checks_allowed(host_id) == 'True' %}

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
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

'{{ case_name }}_{{ selected_role_name }}_{{ selected_host['hostname'] }}_accept_ssh_key_cmd':
    cmd.run:
        - name: '{{ config_temp_dir }}/ssh/accept_host_keys.sh "{{ selected_host['hostname'] }}" "{{ selected_host['username'] }}"'
        {% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
        - user: '{{ account_conf['username'] }}'
        - require:
            - sls: common.ssh
            - file: '{{ config_temp_dir }}/ssh/accept_host_keys.sh'

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

'{{ case_name }}_{{ selected_role_name }}_{{ selected_host['hostname'] }}_accept_ssh_key_cmd':
    cmd.run:
        # The script file potentially does not have execute permissions.
        # Execute through bash-interpreter.
        - name: '{{ cygwin_root_dir }}\bin\bash.exe -l "{{ pillar['windows_config_temp_dir_cygwin'] }}/accept_host_keys.sh" "{{ selected_host['hostname'] }}" "{{ selected_host['username'] }}"'
        - require:
            - sls: common.ssh
            - file: '{{ config_temp_dir }}\accept_host_keys.sh'
            - cmd: 'accept_host_keys_script_dos2unix'

{% endif %}
# >>>
###############################################################################

#------------------------------------------------------------------------------

{% endif %}

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

{% if is_network_checks_allowed(minion_id) == 'True' %}

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
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

'{{ case_name }}_{{ selected_role_name }}_{{ selected_host['hostname'] }}_accept_ssh_key_cmd':
    cmd.run:
        - name: '{{ config_temp_dir }}/ssh/accept_host_keys.sh "{{ selected_host['hostname'] }}" "{{ selected_host['username'] }}"'
        {% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
        - user: '{{ account_conf['username'] }}'
        - require:
            - sls: common.ssh
            - file: '{{ config_temp_dir }}/ssh/accept_host_keys.sh'

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

'{{ case_name }}_{{ selected_role_name }}_{{ selected_host['hostname'] }}_accept_ssh_key_cmd':
    cmd.run:
        # The script file potentially does not have execute permissions.
        # Execute through bash-interpreter.
        - name: '{{ cygwin_root_dir }}\bin\bash.exe -l "{{ pillar['windows_config_temp_dir_cygwin'] }}/accept_host_keys.sh" "{{ selected_host['hostname'] }}" "{{ selected_host['username'] }}"'
        - require:
            - sls: common.ssh
            - file: '{{ config_temp_dir }}\accept_host_keys.sh'
            - cmd: 'accept_host_keys_script_dos2unix'

{% endif %}
# >>>
###############################################################################

#------------------------------------------------------------------------------

{% endfor %} # Inner loop of 2.

{% endif %} # "online"

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

{% if is_network_checks_allowed(None) == 'True' %}

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
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

'{{ case_name }}_{{ hostname }}_{{ selected_host['username'] }}_accept_ssh_key_cmd':
    cmd.run:
        - name: '{{ config_temp_dir }}/ssh/accept_host_keys.sh "{{ selected_host['hostname'] }}" "{{ selected_host['username'] }}"'
        {% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
        - user: '{{ account_conf['username'] }}'
        - require:
            - sls: common.ssh
            - file: '{{ config_temp_dir }}/ssh/accept_host_keys.sh'

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

'{{ case_name }}_{{ hostname }}_{{ selected_host['username'] }}_accept_ssh_key_cmd':
    cmd.run:
        # The script file potentially does not have execute permissions.
        # Execute through bash-interpreter.
        - name: '{{ cygwin_root_dir }}\bin\bash.exe -l "{{ pillar['windows_config_temp_dir_cygwin'] }}/accept_host_keys.sh" "{{ selected_host['hostname'] }}" "{{ selected_host['username'] }}"'
        - require:
            - sls: common.ssh
            - file: '{{ config_temp_dir }}\accept_host_keys.sh'
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


