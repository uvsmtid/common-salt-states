# This example configuration file is only for testing of bootstrap scripts.
# It has every step disabled to avoid maintaining detailed configuraiton.
# If sample configuration is needed, generate it using Salt's
# `bootstrap.bootstrap.provide_content` state.

target_platform = 'rhel7'

project_name = 'examples'

profile_name = 'uvsmtid'

system_host_id = 'centos-7.0-minimal'

# Example configuration for `build` action

copy_everything = {
    'step_enabled': False,
}

pack_everything = {
    'step_enabled': False,
}

# Example configuration for `deploy` action

init_ip_route = {
    'step_enabled': False,
}

init_dns_server = {
    'step_enabled': False,
}

make_salt_resolvable = {
    'step_enabled': False,
}

set_hostname = {
    'step_enabled': False,
}

create_primary_user = {
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

