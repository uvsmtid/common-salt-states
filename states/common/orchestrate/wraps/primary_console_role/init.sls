# Configure `primary_console_role` role.

{% if 'primary_console_role' in pillar['system_host_roles'] %}

{% if grains['id'] in pillar['system_host_roles']['primary_console_role']['assigned_hosts'] %}

include:

    - common.shell.prompt
    - common.shell.aliases
    - common.shell.variables

    - common.tmux

{% endif %}

{% endif %}

