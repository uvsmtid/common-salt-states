
###############################################################################
#

include:

{% for sub_item in [
        'source_bootstrap_configuration'
        ,
        'target_bootstrap_configuration'
        ,
        'static_bootstrap_configuration'
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

