
###############################################################################
#

include:

{% for sub_item in [
        'main'
        ,
        'external_http_proxy_password'
        ,
        'smtp_connection_settings_auth_password'
        ,
        'windows_server_2012_R2_gui_1_0_0_box_administrator_password'
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

