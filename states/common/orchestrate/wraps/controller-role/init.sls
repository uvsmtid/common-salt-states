# Configure `controller-role` role (Salt master).

{% if grains['id'] in pillar['system_host_roles']['controller-role']['assigned_hosts'] %}

include:

    - common.source_symlinks

    - common.ssh.accept_host_keys
    - common.ssh.distribute_public_keys

    # TODO
    #- common.salt.master

{% endif %}

