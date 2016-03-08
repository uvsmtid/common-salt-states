
###############################################################################
#

include:

{% for sub_item in [
        'main'
        ,
        'ssh_keys'
        ,
        'sonar_qube'
        ,
        'wildfly'
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

