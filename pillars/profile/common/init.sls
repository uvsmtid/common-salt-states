
###############################################################################
#

# This is relative include mechanics as a workaround to inability to
# include pillar relative to current directory:
#    https://github.com/saltstack/salt/issues/8875#issuecomment-89441029

include:

{% for sub_item in [
        'main'
        ,
        'common_pillar_schema_version'
        ,
        'system_hosts'
        ,
        'system_host_roles'
        ,
        'system_networks'
        ,
        'registered_content_items'
        ,
        'system_features'
    ]
%}
    - {{ this_pillar }}.{{ sub_item }}:
        defaults:
            this_pillar: {{ this_pillar }}.{{ sub_item }}

{% endfor %}

###############################################################################
# EOF
###############################################################################

