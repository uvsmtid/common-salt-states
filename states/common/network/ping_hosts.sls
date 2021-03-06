# Ping all defined hosts.

{% from 'common/libs/utils.lib.sls' import get_salt_content_temp_dir with context %}

{% from 'common/libs/host_config_queries.sls' import is_network_checks_allowed with context %}

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

'{{ get_salt_content_temp_dir() }}/ssh/ping_host.sh':
    file.managed:
        - source: salt://common/network/ping_host.sh
        - template: jinja
        {% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
        - user: {{ account_conf['username'] }}
        - group: {{ account_conf['primary_group'] }}
        - makedirs: True
        - mode: 544

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
        'password_secret': account_conf['password_secret']
    }
%}

#------------------------------------------------------------------------------
'{{ case_name }}_ping_remote_hosts_{{ selected_role_name }}_{{ selected_account['hostname'] }}_cmd':
    cmd.run:
        - name: '{{ get_salt_content_temp_dir() }}/ssh/ping_host.sh "{{ selected_account['hostname'] }}" "{{ selected_account['username'] }}"'
        {% set local_account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
        - user: {{ local_account_conf['username'] }}
        - require:
            - file: '{{ get_salt_content_temp_dir() }}/ssh/ping_host.sh'
#------------------------------------------------------------------------------

{% endif %}

{% endfor %} # Outter loop of 1.


{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

{% endif %}
# >>>
###############################################################################

