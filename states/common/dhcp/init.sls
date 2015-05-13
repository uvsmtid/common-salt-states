# DHCP configuration.

{% if grains['id'] in pillar['system_host_roles']['resolver-role']['assigned_hosts'] %}

{% set hostname_res = pillar['system_features']['hostname_resolution_config'] %}

{% if hostname_res['hostname_resolution_type'] == 'named_and_dhcpd_services' %}

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}


dhcp_server:
    pkg.installed:
        - name: dhcp
        - aggregate: True
    service.running:
        - name: dhcpd
        - enable: True
        - watch:
            - file: /etc/dhcp/dhcpd.conf

/etc/dhcp/dhcpd.conf:
    file.managed:
        - source: salt://common/dhcp/dhcpd.conf
        - user: root
        - group: root
        - mode: 644
        - template: jinja

{% endif %}
# >>>
###############################################################################

{% endif %}

{% endif %}

# If no states are run, `salt.orchestrate` fails seeing 0 totals.
# See also:
#     https://github.com/saltstack/salt/issues/14553
include:
    - common.dummy

