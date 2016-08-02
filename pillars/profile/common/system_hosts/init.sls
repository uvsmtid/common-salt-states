
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
        'winserv2012_minion'
        ,
        'shared_jenkins'
        ,
        'shared_nexus'
        ,
        'shared_sonarqube'
        ,
        'shared_vagrant_box_publisher'
        ,
        'shared_local_yum_mirrors'
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

