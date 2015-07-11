
###############################################################################
#

include:

{% for sub_item in [
        'primary_net'
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

