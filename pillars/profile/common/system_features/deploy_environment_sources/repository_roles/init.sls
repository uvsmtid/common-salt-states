
###############################################################################
#

include:

{% for sub_item in [
        'top_level_parent_role'
        ,
        'project_states_role'
        ,
        'source_profile_pillars_role'
        ,
        'target_profile_pillars_role'
        ,
        'build_history_role'
        ,
        'taggable_repository_role'
        ,
        'maven_project_container_role'
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

