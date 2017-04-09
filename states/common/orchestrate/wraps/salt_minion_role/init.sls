# Configure `salt_minion_role` role (Salt minion).

{% if 'salt_minion_role' in pillar['system_host_roles'] %}

{% if grains['id'] in pillar['system_host_roles']['salt_minion_role']['assigned_hosts'] %}

include:

    - common.orchestrate.wraps.salt_minion_role.minimal

    - common.firewall

    - common.shell.prompt
    - common.shell.aliases
    - common.shell.variables

    # Set splash screen and boot console resolution.
    - common.grub

    - common.system_version

    - common.sudo
    - common.sudo.configure_required_users

    - common.vim

    - common.git

    - common.yum

    # Prepare seamless SSH connectivity.
    - common.ssh.distribute_private_keys
    # NOTE: Distribution of public keys is done from control host.
    #-common.ssh.distribute_public_keys
    - common.ssh.accept_host_keys

    - common.gnome.system_proxy
    - common.gnome.auto_login

    - common.packages_per_os_platfrom_type

    - common.windows_power

    - common.custom_root_ca

    - common.selinux

    - common.java

    - common.timezone

{% endif %}

{% endif %}

