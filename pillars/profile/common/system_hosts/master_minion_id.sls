
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set master_minion_id = props['master_minion_id'] %}
{% set primary_network = props['primary_network'] %}

# Disable this host definition if it is defined somewhere else
# (when Salt master is set up on a minion defined in another file).
{% if props['use_master_minion_template_host'] %}

{% if master_minion_id in props['enabled_minion_hosts'].keys() %}

system_hosts:

    {{ master_minion_id }}:

        instantiated_by: ~
        vagrant_instance_configuration:
            vagrant_provider: 'libvirt'
            # Example values for `base_images` depending on `vagrant_provider`:
            #   - 'uvsmtid/fedora-21-server-minimal' # libvirt
            #   - 'uvsmtid/centos-5.5-minimal' # libvirt
            #   - 'uvsmtid/centos-7.0-minimal' # libvirt
            #   - 'hansode/fedora-21-server-x86_64' # virtualbox
            #   - 'fedora:21' # docker
            base_image: 'uvsmtid/fedora-21-server-minimal' # libvirt
            memory_size: 2048
            cpus_number: 2

        # NOTE: Fedora is fast-moving distribution.
        #       Select `fc22`, `fc23`, `fc24`, ...
        os_platform: fc22

        hostname: {{ master_minion_id }}
        # The master minion host is defined in `primary_network`
        # which is not controlled by Salt (directly or indirectly, e.g.
        # through configuration of some virtualized networks) and
        # exist to contact minions before running any Salt states.
        resolved_in: {{ primary_network['network_name'] }}
        consider_online_for_remote_connections: True
        host_networks:

            {{ primary_network['network_name'] }}:
                ip: {{ props['enabled_minion_hosts'][master_minion_id] }}

            internal_net_A:
                ip: 192.168.51.1
            internal_net_B:
                ip: 192.168.52.1
            external_net_A:
                ip: 192.168.61.1
            external_net_B:
                ip: 192.168.62.1

        primary_user: master_minion_user

{% endif %}

{% endif %}

###############################################################################
# EOF
###############################################################################

