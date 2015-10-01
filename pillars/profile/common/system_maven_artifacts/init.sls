
###############################################################################
#

include:

{% for sub_item in [
        'artifact_descriptors'
        ,
        'pom_file_exceptions'
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

