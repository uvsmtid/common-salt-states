
###############################################################################
#
# Central source repository configuration.
# The following values are passed to templates for descriptor and
# job configuration to let control scripts complete the task of
# deploying environement sources.
#   `salt_master_local_path*`
#
#     Specify path of manually checked out directory on Salt master.
#
#     The `*_base` part specifies path which is likely to change
#     from one environment to another. And the `*_rest` part specifies
#     what is likely to stay the same. This is to simplify visual
#     comparision and highlight only the changes which matter (which
#     are those in `*_base`).
#
#   `origin_url`
#     For Git only.
#     Specify remote URL (origin) to clone repo on all minions.
#   `root_url`
#     For Subversion only.
#     Specify root URL of repository.
#   `branch_path`
#     For Subversion only.
#     Specify path to branch relative to repository root URL.

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

