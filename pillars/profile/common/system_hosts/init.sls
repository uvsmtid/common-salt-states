
###############################################################################
#

include:

{% for sub_item in [
        'localhost_host'
        ,
        'master_minion_id'
        ,
        'rhel5_minion'
        ,
        'rhel7_minion'
        ,
        'fedora_minion'
        ,
        'jenkins'
        ,
        'nexus'
        ,
        'sonar'
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

