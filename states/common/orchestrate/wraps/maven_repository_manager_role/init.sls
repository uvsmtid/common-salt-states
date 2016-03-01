# Configure `maven_repository_manager_role` roles:
# - maven_repository_upstream_manager_role
# - maven_repository_downstream_manager_role

{% for selected_role in [ 'maven_repository_upstream_manager_role', 'maven_repository_downstream_manager_role' ] %}

{% if selected_role in pillar['system_host_roles'] %}

{% if grains['id'] in pillar['system_host_roles'][selected_role]['assigned_hosts'] %}

include:

    - common.nexus

{% endif %}

{% endif %}

{% endfor %}

