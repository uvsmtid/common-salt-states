# Components applicable for all hosts.

include:

    - common.orchestrate.wraps.primary

    - common.sudo
    - common.sudo.configure_required_users

    - common.vim

    - common.git

    # Prepare seamless SSH connectivity.
    - common.ssh.distribute_private_keys
    # NOTE: Distribution of public keys is done from control host.
    #-common.ssh.distribute_public_keys
    - common.ssh.accept_host_keys

    - common.gnome.system_proxy

    - common.packages_per_os_platfrom_type

