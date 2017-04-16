
###############################################################################
#
# This is passed to override descriptor configuration on control
# scripts command line. It could probably be placed directly in
# Git configuration below (as it is in descriptor), but composing
# this data in templates is awkward while this makes it is ready to
# use (just like another similar override config `source_repo_types`)
# via rendering into JSON.
#
# Local path per Git repo:
# - if absolute, it is single for all checkouts;
# - if relative, it is single per job (control scripts).

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

