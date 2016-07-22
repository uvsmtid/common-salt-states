# Configure `salt_master_role` role (Salt master).

{% if 'salt_master_role' in pillar['system_host_roles'] %}

{% if grains['id'] in pillar['system_host_roles']['salt_master_role']['assigned_hosts'] %}

include:

    - common.source_symlinks

    - common.ssh.accept_host_keys
    - common.ssh.distribute_public_keys

    # TODO
    #- common.salt.master

{% endif %}

{% endif %}

