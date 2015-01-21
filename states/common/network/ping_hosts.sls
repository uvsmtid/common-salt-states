# Ping all defined hosts.

{% if grains['kernel'] == 'Linux' %}
{% set config_temp_dir = pillar['posix_config_temp_dir'] %}
{% endif %}
{% if grains['kernel'] == 'Windows' %}
{% set config_temp_dir = pillar['windows_config_temp_dir'] %}
{% endif %}

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

'{{ config_temp_dir }}/ssh/ping_host.sh':
    file.managed:
        - source: salt://common/network/ping_host.sh
        - template: jinja
        - user: {{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}
        - group: {{ pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}
        - makedirs: True
        - mode: 544

{% set case_name = 'all_defined_hosts' %}

{% set selected_role_name = 'none' %}

{% set all_defined_hosts = pillar['system_hosts'].values() %}

{% for host_config in all_defined_hosts %}

{% if host_config['consider_online_for_remote_connections'] %}

# Compose expected data object:
{% set selected_account = { 'hostname': host_config['hostname'], 'username': host_config['primary_user']['username'], 'password': host_config['primary_user']['password'] } %}

#------------------------------------------------------------------------------
# Distribute the key:
'{{ case_name }}_ping_remote_hosts_{{ selected_role_name }}_{{ selected_account['hostname'] }}_cmd':
    cmd.run:
        - name: '{{ config_temp_dir }}/ssh/ping_host.sh "{{ selected_account['hostname'] }}" "{{ selected_account['username'] }}"'
        - user: {{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}
        - require:
            - file: '{{ config_temp_dir }}/ssh/ping_host.sh'
#------------------------------------------------------------------------------

{% endif %}

{% endfor %} # Outter loop of 1.


{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

{% endif %}
# >>>
###############################################################################
