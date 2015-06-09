# Configuration of NAT for firewalld.

###############################################################################
# <<< Service firewalld exists only in Fedora.
{% if grains['os_platform_type'].startswith('rhel7') or grains['os_platform_type'].startswith('fc') %}

include:
    - common.firewall

extend:
    firewall:
        service:
            - watch:
                - file: /etc/firewalld/direct.xml

# TODO: If more rules are required, the following files should rather be
#       patched than overwritten.

/etc/firewalld/direct.xml:
    file.managed:
        - source: salt://common/firewall/nat/direct.xml
        - user: root
        - group: root
        - mode: 600

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel5') %}

    # TODO: configure iptables for NAT.

{% endif %}
# >>>
###############################################################################

