
###############################################################################
#

include:

{% for sub_item in [
        'main'
        ,
        'ssh_keys'
        ,
        'sonarqube'
        ,
        'wildfly'
        ,
        'maven'
        ,
        'vagrant_boxes'
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

