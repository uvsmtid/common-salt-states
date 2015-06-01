# Macros in this files simplify access to `system_secrets` pillar.

# Secrets can be encoded as:
# - single-line value
# - multi-line value
# In order to use them for Jinja, there should be different function
# to insert these values into templates so that YAML parsing won't break.

# In addition to this, in order to provide binary values, base64 encoding
# is used (which is always multiline). Binary (base64-encoded) data is
# only used for deployment into a file (not into sls template).

{%- macro get_single_line_system_secret_from_pillar(secret_id, pillar_data) -%}
{%- set system_secret_value = pillar_data['system_secrets'][secret_id] -%}
{{- system_secret_value -}}
{%- endmacro -%}

{%- macro get_single_line_system_secret(secret_id) -%}
{{- get_single_line_system_secret_from_pillar(secret_id, pillar) -}}
{%- endmacro -%}

