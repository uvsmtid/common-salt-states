
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set master_minion_id = props['master_minion_id'] %}

{% set pillars_macro_lib = 'lib/pillars_macro_lib.sls' %}
{% from pillars_macro_lib import filter_assigned_hosts_by_minion_hosts_enabled_in_properties with context %}

system_host_roles:

    # Primary console is the machine which user/developer
    # interacts with to control the rest of the system.
    # For example, it normally (not necessarily) provides graphical environment
    # (to use browser to access Jenkins), it may provide
    # X server to run remote apps with graphical interface,
    # shell is configured with informative prompts, etc.
    primary_console_role:
        hostname: primary-console-role-host
        assigned_hosts:
            # NOTE: We include all default minions for demo.
            {{ filter_assigned_hosts_by_minion_hosts_enabled_in_properties([
                    master_minion_id,

                    'rhel5_minion',
                    'rhel7_minion',
                    'fedora_minion',
                    'winserv2012_minion',

                ], props)
            }}

###############################################################################
# EOF
###############################################################################

