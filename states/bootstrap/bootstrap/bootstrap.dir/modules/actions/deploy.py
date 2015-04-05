import logging

from context import action_context

###############################################################################
#
class deploy_template_method (action_context):

    ###########################################################################
    # See base class for pythondoc.

    action_step_to_use_case_map = {

        "init_ip_route": "always",

        "init_dns_server": "always",

        # Salt will never contact master in `offline-minion-installer`
        # user case.
        "make_salt_resolvable": [
            'initial-online-node',
        ],

        "set_hostname": "always",

        "create_primary_user": "always",

        "init_yum_repos": "always",

        "install_salt_master": [
            'initial-online-node',
        ],

        "install_salt_minion": "always",

        # Sources are linked only on machines which have access to them.
        "link_sources": [
            'initial-online-node',
            'offline-minion-installer',
        ],

        # Sources are linked only on machines which have access to them.
        "link_resources": [
            'initial-online-node',
            'offline-minion-installer',
        ],

        "activate_salt_master": [
            'initial-online-node',
        ],

        # Note that Salt minion is not activated for `offline-minion-installer`.
        "activate_salt_minion": [
            'initial-online-node',
        ],

        "run_init_states": "always",

        "run_highstate": [
            'offline-minion-installer',
        ],
    }

    ###########################################################################
    # See base class for pythondoc.

    action_step_ordered_execution_list = [
        "init_ip_route",
        "init_dns_server",
        "make_salt_resolvable",
        "set_hostname",
        "create_primary_user",
        "init_yum_repos",
        "install_salt_master",
        "install_salt_minion",
        "link_sources",
        "link_resources",
        "activate_salt_master",
        "activate_salt_minion",
        "run_init_states",
        "run_highstate",
    ]

###############################################################################
# EOF
###############################################################################

