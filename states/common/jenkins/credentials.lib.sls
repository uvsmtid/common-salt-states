# This macro is a single definition for format of Jenkins credentials id.

# If framework is extended to support different types of credentials,
# their id should probably be re-defined here to stay unique.

# Jenkins credentials id: [username]@[hostname]_credentials.
{%- macro get_jenkins_credentials_id_by_host_id(host_id) -%}
{%- set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] -%}
{{ account_conf['username'] }}@{{ pillar['system_hosts'][host_id]['hostname'] }}_credentials
{%- endmacro -%}

