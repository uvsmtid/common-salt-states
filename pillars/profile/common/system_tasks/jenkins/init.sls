
###############################################################################
#

# This is relative include mechanics as a workaround to inability to
# include pillar relative to current directory:
#    https://github.com/saltstack/salt/issues/8875#issuecomment-89441029

include:

{% for sub_item in [
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

