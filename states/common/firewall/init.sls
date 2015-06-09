##############################################################################
# Determine task based on different os flavor
##############################################################################

{% if grains['os_platform_type'].startswith('fc') or grains['os_platform_type'].startswith('rhel7') %}
    {% set task = 'firewalld' %}
{% elif grains['os_platform_type'].startswith('rhel5') %}
    {% set task = 'iptables' %}
{% elif grains['os_platform_type'].startswith('win') %}
    {% set task = 'windows' %}
{% else %}
    {{ FAIL_UNKNOWN_PLATFORM }}
{% endif %}

###############################################################################
{% if task  == 'firewalld' %}
# Configuration file for `firewalld`.
# NOTE: We don't disable firewall, we remove all restrictions.
#       We also assume it hosts VMs and the better option is to have NAT
#       instead of blocking routed traffic.

firewall:
    pkg.installed:
        - name: firewalld
        - aggregate: True
    service.running:
        - name: firewalld
        - enable: True
        - require:
            - pkg: firewall
        - watch:
            - file: /etc/firewalld/firewalld.conf
            - file: /etc/firewalld/zones/trusted.xml

# NOTE: At the time of initial configuration the following file enabled
#       trusted zone (allowing all connection). The firewall was primarily
#       needed for masquerade/NAT isolated network with VMs.
#       Review configuration, if requirements are different.

/etc/firewalld/firewalld.conf:
    file.managed:
        - source: salt://common/firewall/firewalld.conf
        - user: root
        - group: root
        - mode: 600

/etc/firewalld/zones/trusted.xml:
    file.managed:
        - source: salt://common/firewall/trusted.xml
        - user: root
        - group: root
        - mode: 600

{% endif %}
###############################################################################

###############################################################################
{% if task == 'iptables' %}

# Simply disable iptables on all RHEL5 nodes.
firewall:
    service.dead:
        - name: iptables
        - enable: False

{% endif %}
###############################################################################

###############################################################################
{% if task == 'Windows' %}

# See also:
#   http://technet.microsoft.com/en-us/library/cc766337(v=ws.10).aspx
#   http://www.windowscommandsyntax.com/howto/disable-windows-firewall-from-a-command-prompt/

disable_windows_firewall:
    cmd.run:
        - name: "netsh advfirewall set AllProfiles state off"

{% endif %}
###############################################################################

