# GDM configuration storage

[daemon]
# Uncoment the line below to force the login screen to use Xorg
#WaylandEnable=false

{% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
{% if 'enable_primary_user_auto_login' in pillar['system_features'] and pillar['system_features']['enable_primary_user_auto_login'] %}
# Auto-login specified user after reboot.
AutomaticLoginEnable = true
AutomaticLogin = {{ account_conf['username'] }}
{% endif %}

[security]

[xdmcp]

[chooser]

[debug]
# Uncomment the line below to turn on debugging
#Enable=true

