
###############################################################################
#

include:

{% for sub_item in [
        'artifact_descriptors'
        ,
        'pom_file_exceptions'
        ,
        'maven_reactor_root_pom'
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

