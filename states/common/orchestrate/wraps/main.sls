# Components applicable for all hosts.

include:

    {% set hostname_res = pillar['system_features']['hostname_resolution_config'] %}

    {% if hostname_res['hostname_resolution_type'] == 'static_hosts_file' %}

    # Generate hosts files on minions.
    - common.hosts_file

    {% endif %}

    - common.firewall

    - common.sudo
    - common.sudo.configure_required_users

    - common.shell.prompt
    - common.shell.aliases
    - common.shell.variables

    - common.vim

    - common.git

    # Set splash screen and boot console resolution.
    - common.grub

    # Prepare seamless SSH connectivity.
    - common.ssh.distribute_private_keys
    # NOTE: Distribution of public keys is done from control host.
    #-common.ssh.distribute_public_keys
    - common.ssh.accept_host_keys

