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

