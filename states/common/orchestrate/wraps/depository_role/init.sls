# Configure `depository_role` role.

{% if grains['id'] in pillar['system_host_roles']['depository_role']['assigned_hosts'] %}

include:

    - common.webserver.depository_role

    #- common.webserver.depository_role.check_content

    - common.webserver.depository_role.setup_control_directory

{% endif %}

