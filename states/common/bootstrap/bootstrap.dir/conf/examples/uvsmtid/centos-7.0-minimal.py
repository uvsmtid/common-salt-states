# This example configuration file is only for testing of bootstrap scripts.
# It has every step disabled to avoid maintaining detailed configuraiton.
# If sample configuration is needed, generate it using Salt's
# `common.bootstrap.provide_content` state.

target_platform = 'rhel7'

init_ip_route = {
    'step_enabled': False,
}

init_dns_server = {
    'step_enabled': False,
}

make_salt_resolvable = {
    'step_enabled': False,
}

init_yum_repos = {
    'step_enabled': False,
}

install_salt_master = {
    'step_enabled': False,
}

install_salt_minion = {
    'step_enabled': False,
}

link_sources = {
    'step_enabled': False,
}

link_resources = {
    'step_enabled': False,
}

activate_salt_master = {
    'step_enabled': False,
}

activate_salt_minion = {
    'step_enabled': False,
}

run_init_states = {
    'step_enabled': False,
}

run_highstate = {
    'step_enabled': False,
}


