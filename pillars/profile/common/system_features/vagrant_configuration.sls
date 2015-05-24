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
            primary_vagrant_private_net:
                enabled: True
                vagrant_net_type: 'private_network'
                enable_dhcp: True
                system_network: internal_net
            secondary_vagrant_private_net:
                enabled: True
                vagrant_net_type: 'private_network'
                enable_dhcp: True
                system_network: secondary_internal_net
            primary_vagrant_public_net:
                enabled: True
                vagrant_net_type: 'public_network'
                enable_dhcp: True
                system_network: external_net
                host_bridge_interface: em1
            secondary_vagrant_public_net:
                enabled: True
                vagrant_net_type: 'public_network'
                enable_dhcp: True
                system_network: secondary_external_net
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

