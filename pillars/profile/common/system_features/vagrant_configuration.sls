
# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set primary_network = props['primary_network'] %}

###############################################################################
#

system_features:

    vagrant_configuration:
        # Location of Vagrantfile relative to primary users' home.
        vagrant_files_dir: 'vagrant.dir'

        vagrant_provider: 'libvirt'

        #vagrant_bootstrap_use_case: 'offline-minion-installer'
        #vagrant_bootstrap_use_case: 'initial-online-node'
        vagrant_bootstrap_use_case: 'initial-online-node'

        # Specify Vagrant networks:
        #
        # * Vagrant "private networks" (which is essentially
        #   host-only networking and has the meaning of using IP addresses
        #   from private IP address space).
        #
        #   See: http://docs.vagrantup.com/v2/networking/private_network.html
        #
        # * Specify Vagrant "public networks" (which is essentially
        #   bridged networking requiring MAC address to be used in
        #   virtual switch).
        #
        #   See: http://docs.vagrantup.com/v2/networking/public_network.html
        #
        vagrant_networks:

            vagrant_{{ primary_network['network_name'] }}:
                enabled: True
                vagrant_net_type: 'private_network'
                enable_dhcp: True
                system_network: {{ primary_network['network_name'] }}

            vagrant_internal_net_A:
                enabled: True
                vagrant_net_type: 'private_network'
                enable_dhcp: True
                system_network: internal_net_A
            vagrant_internal_net_B:
                enabled: True
                vagrant_net_type: 'private_network'
                enable_dhcp: True
                system_network: internal_net_B

            vagrant_external_net_A:
                enabled: False
                vagrant_net_type: 'public_network'
                enable_dhcp: True
                system_network: external_net_A
                host_bridge_interface: em1
            vagrant_external_net_B:
                enabled: False
                vagrant_net_type: 'public_network'
                enable_dhcp: True
                system_network: external_net_B
                host_bridge_interface: em1

        vagrant_providers_configs:
            'virtualbox':
                deployment_state: common.virtualbox
            'docker':
                deployment_state: common.docker
            'libvirt':
                deployment_state: common.libvirt

###############################################################################
# EOF
###############################################################################

