
###############################################################################
#

include:

{% for sub_item in [
        'parent_repo_name'
        ,
        'common-salt-states'
        ,
        'project_name-salt-states'
        ,
        'common-salt-resources' 
        ,
        'project_name-salt-resources'
        ,
        'project_name-salt-pillars'
        ,
        'project_name-salt-pillars_bootstrap-target'
        ,
        'project_name-build-history'
        ,
        'maven_repo_names' 
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

