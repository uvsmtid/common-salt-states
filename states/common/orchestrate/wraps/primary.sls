# Primary configuration for any host.

include:

    {% set hostname_res = pillar['system_features']['hostname_resolution_config'] %}

    {% if hostname_res['hostname_resolution_type'] == 'static_hosts_file' %}

    # Generate hosts files on minions.
    - common.hosts_file

    {% endif %}

    - common.firewall

    - common.shell.prompt
    - common.shell.aliases
    - common.shell.variables

    - common.tmux

    # Set splash screen and boot console resolution.
    - common.grub
