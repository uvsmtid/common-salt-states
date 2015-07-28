# Default installation of `pgAdmin`

###############################################################################
# [[[[[
{% if grains['os_platform_type'].startswith('fc') %}

pgadmin:
    pkg.installed:
        - name: pgadmin3
        - aggregate: True

{% endif %}
# ]]]]]
###############################################################################


