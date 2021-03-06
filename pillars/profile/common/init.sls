
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
        'system_build_descriptor'
        ,
        'system_maven_artifacts'
        ,
        'system_platforms'
        ,
        'system_secrets'
        ,
        'system_accounts'
        ,
        'system_hosts'
        ,
        'system_host_roles'
        ,
        'system_networks'
        ,
        'system_resources'
        ,
        'system_features'
        ,
        'system_orchestrate_stages'
        ,
        'system_tasks'
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

