
###############################################################################
#

include:

# NOTE: Fedora realeases are fast-rolling.
#       Use the same platform definition file (while it makes sense).
{% for sub_item in [
        'fc00'
        ,
        'rhel5'
        ,
        'rhel7'
        ,
        'win7'
        ,
        'winserv2012'
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

