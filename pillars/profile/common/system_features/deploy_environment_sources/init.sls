
###############################################################################
#

include:

{% for sub_item in [
        'main'
        ,
        'git_repo_local_paths'
        ,
        'repository_roles'
        ,
        'source_repositories'
        ,
        'source_repo_types'
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

