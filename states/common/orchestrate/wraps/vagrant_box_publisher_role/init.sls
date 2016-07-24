# Configure `vagrant_box_publisher_role` role.

{% if 'vagrant_box_publisher_role' in pillar['system_host_roles'] %}

{% if grains['id'] in pillar['system_host_roles']['vagrant_box_publisher_role']['assigned_hosts'] %}

include:

    - common.webserver.vagrant_box_publisher_role

{% endif %}

{% endif %}

