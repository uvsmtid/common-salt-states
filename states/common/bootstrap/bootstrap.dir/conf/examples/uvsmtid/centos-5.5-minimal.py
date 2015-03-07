# This example configuration file is only for testing of bootstrap scripts.
# Normally, this configuration is generated by bootstrap Salt state.

target_platform = 'rhel5'

init_ip_route = {
    'step_enabled': True,

    # IP address to route IP traffic by default.
    'default_route_ip': '192.168.50.1',

    # IP address behind network router to confirm successful routing configuration.
    'remote_network_ip': '8.8.8.8',

}

init_dns_server = {
    'step_enabled': True,

    'resolv_conf_file': 'resources/examples/uvsmtid/centos-5.5-minimal/resolv.conf',

    'dns_server_ip': '8.8.8.8',

    'remote_hostname': 'google.com',

}

make_salt_resolvable = {
    'step_enabled': True,

    'required_entries_hosts_file': 'resources/examples/uvsmtid/centos-5.5-minimal/hosts_file',

}

init_yum_repos = {
    'step_enabled': True,

    "yum_repo_configs": {

        "base": {
            "installation_type": "file",
            # TODO
        },

        "epel": {
            "installation_type": "rpm",
            "rpm_key_file": "resources/examples/uvsmtid/centos-5.5-minimal/RPM-GPG-KEY-EPEL-5.217521F6.key.txt",
            # TODO
        },

        "pgdg": {
            "installation_type": "rpm",
            # TODO
        },
    },

}

install_salt_master = {
    'step_enabled': True,

    "src_salt_config_file": "resources/examples/uvsmtid/centos-5.5-minimal/master.conf",
    "dst_salt_config_file": "/etc/salt/master",

    "rpm_sources": {
        "salt-master": {
            "source_type": "zip",
            "file_path": "resources/examples/uvsmtid/centos-5.5-minimal/salt-master-2014.7.1-1.el5.x86_64.rpms.zip",
        },
        "python26-distribute": {
            "source_type": "zip",
            "file_path": "resources/examples/uvsmtid/centos-5.5-minimal/python26-distribute-0.6.10-4.el5.x86_64.rpms.zip",
        },
    },

}

install_salt_minion = {
    'step_enabled': True,

    "src_salt_config_file": "resources/examples/uvsmtid/centos-5.5-minimal/minion.conf",
    "dst_salt_config_file": "/etc/salt/minion",

    "rpm_sources": {
        "salt-master": {
            "source_type": "zip",
            "file_path": "resources/examples/uvsmtid/centos-5.5-minimal/salt-minion-2014.7.1-1.el5.x86_64.rpms.zip",
        },
        "python26-distribute": {
            "source_type": "zip",
            "file_path": "resources/examples/uvsmtid/centos-5.5-minimal/python26-distribute-0.6.10-4.el5.x86_64.rpms.zip",
        },
    },

}

link_sources = {
    'step_enabled': True,

    # Configure each extracted respository.
    'repos': {
        'common-salt-states': {
            'repo_type': 'git',
            'archive_type': 'tar',
        },
    },

}

link_resources = {
    'step_enabled': True,
    # TODO
}

activate_salt_master = {
    'step_enabled': True,

    'service_name': 'salt-master',

}

activate_salt_minion = {
    'step_enabled': True,

    'service_name': 'salt-minion',

}

run_init_states = {
    'step_enabled': True,
    # TODO
}

run_highstate = {
    'step_enabled': True,
    # TODO
}


