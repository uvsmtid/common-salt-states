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

        # Specify Vagrant "private networks" (which is essentially
        # host-only networking and has the meaning of using IP addresses
        # from private IP address space).
        #
        # See: http://docs.vagrantup.com/v2/networking/private_network.html
        private_networks:
            private_network:
                enabled: True
                system_network: internal_net

        # Specify Vagrant "public networks" (which is essentially
        # bridged networking requiring MAC address to be used in
        # virtual switch).
        #
        # See: http://docs.vagrantup.com/v2/networking/public_network.html
        public_networks:
            public_network:
                enabled: False
                system_network: external_net
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

