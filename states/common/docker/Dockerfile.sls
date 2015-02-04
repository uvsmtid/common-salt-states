#

{% set selected_host = pillar['system_hosts'][selected_host_name] %}
{% set instantiated_by = selected_host['instantiated_by'] %}
{% set instance_configuration = selected_host[instantiated_by] %}

FROM {{ instance_configuration['docker_base_image'] }}


