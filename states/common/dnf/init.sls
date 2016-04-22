# Global dnf configuration for the node.

###############################################################################
# <<<
{% if not grains['os_platform_type'].startswith('win') %}

dnf_conf:
    file.managed:
        - name: /etc/dnf/dnf.conf
        - source: salt://common/dnf/dnf.conf
        - context:
            selected_pillar: {{ pillar }}
        - user: root
        - group: root
        - makedirs: True
        - dir_mode: 755
        - mode: 644
        - template: jinja

{% endif %} # os_platform_type
# >>>
###############################################################################

