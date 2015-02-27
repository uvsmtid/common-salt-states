# This example configuration file is only for testing of bootstrap scripts.
# Normally, this configuration is generated by bootstrap Salt state.

{% set conf_data = pillar %}

target_platform = 'generic_linux'

init_ip_route = {

    # IP address to route IP traffic by default.
    'default_route_ip': '{{ conf_data['internal_net']['gateway'] }}',

    # IP address behind network router to confirm successful routing configuration.
    'remote_network_ip': '{{ conf_data['internal_net']['dns_server'] }}',

}


