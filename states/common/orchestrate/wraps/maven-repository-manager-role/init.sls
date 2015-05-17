# Configure `maven-repository-manager-role` roles:
# - maven-repository-upstream-manager-role
# - maven-repository-downstream-manager-role

{% for selected_role in [ 'maven-repository-upstream-manager-role', 'maven-repository-downstream-manager-role' ] %}

{% if grains['id'] in pillar['system_host_roles'][selected_role]['assigned_hosts'] %}

include:

    - common.nexus

{% endif %}

{% endfor %}

