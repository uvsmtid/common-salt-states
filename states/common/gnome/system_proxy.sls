# Set URL for HTTP proxy configuration in Gnome.

################################################################################
#

{% if grains['os_platform_type'].startswith('fc') %}

{% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}

{% if pillar['properties']['use_internet_http_proxy'] %}

set_gnome_system_proxy:
    cmd.run:
        - name: "gsettings set org.gnome.system.proxy autoconfig-url '{{ pillar['system_features']['external_http_proxy']['auto_config_url'] }}'"
        - user: {{ account_conf['username'] }}

{% endif %}

{% endif %}

################################################################################
# EOF
################################################################################

