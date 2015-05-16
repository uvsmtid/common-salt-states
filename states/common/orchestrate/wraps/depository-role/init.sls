# Configure `depository-role` role.

{% if grains['id'] in pillar['system_host_roles']['depository-role']['assigned_hosts'] %}

include:

    - common.webserver.depository-role

    #- common.webserver.depository-role.check_content

    - common.webserver.depository-role.setup_control_directory

{% endif %}

