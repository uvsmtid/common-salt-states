
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set primary_network = props['primary_network'] %}

include:


# Include additional networks.
{% for sub_item in [
        primary_network['network_name']
        ,
        'internal_net'
        ,
        'secondary_internal_net'
        ,
        'external_net'
        ,
        'secondary_external_net'
    ]
%}
    - {{ this_pillar }}.{{ sub_item }}:
        defaults:
            this_pillar: {{ this_pillar }}.{{ sub_item }}
            profile_root: {{ profile_root }}

{% endfor %}

###############################################################################
# EOF
###############################################################################

