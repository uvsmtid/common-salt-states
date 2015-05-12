
################################################################################
# This state hardcodes current version of pillar schema (data structure).
{% set common_pillar_schema_version = '0.0.0' %}

# It also verifies that declared version of pillar schema specified in
# profile configuration data matches with the current version.

{% if common_pillar_schema_version != pillar['common_pillar_schema_version'] %}
{{ ERROR_pillar_schema_versions_do_not_match }}
{% endif %}

################################################################################
# EOF
################################################################################

