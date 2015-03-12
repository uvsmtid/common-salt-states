import logging

from context import action_context

###############################################################################
#
class deploy_template_method (action_context):

    """
    This dict maps action step to use case based on applicability.

    If action step is mapped into a list, it is only appliacable for the
    specified list of use cases.

    if action step is mapped to string "always", it is appliacable to
    all use cases.

    Anything else is error.
    """
    action_step_to_use_case_map = {

        "init_ip_route": "always",

        "init_dns_server": "always",

        "make_salt_resolvable": "always",

        "set_hostname": "always",

        "create_primary_user": "always",

        "init_yum_repos": "always",

        "install_salt_master": [
            'initial-master',
        ],

        "install_salt_minion": "always",

        # Sources are linked only on machines which have access to them.
        "link_sources": [
            'initial-master',
            'offline-minion-installer',
        ],

        # Sources are linked only on machines which have access to them.
        "link_resources": [
            'initial-master',
            'offline-minion-installer',
        ],

        "activate_salt_master": [
            'initial-master',
        ],

        # Note that Salt minion is not activated for `offline-minion-installer`.
        "activate_salt_minion": [
            'initial-master',
            'online-minion',
        ],

        "run_init_states": "always",

        "run_highstate": [
            'offline-minion-installer',
        ],
    }

    """
    Ordered list of step execution.

    Because lists are ordered in Python and dict keys are not, use this
    list to order the step execution.
    """
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

    ###########################################################################
    #
    def do_action_wrapper(
        self,
        step_name,
    ):

        # Check that this action is applicable for this use case.
        if isinstance(
            self.action_step_to_use_case_map[step_name],
            list,
        ):
            if self.run_case not in self.action_step_to_use_case_map:
                logging.debug("skip not applicable step: " + step_name)
        else:
            # At this point the only allowed value is "always".
            if "always" != self.action_step_to_use_case_map[step_name]:
                raise RuntimeError

        # Get object which configures `step_name`.
        step_config = getattr(self.conf_m, step_name)

        if step_config['step_enabled']:
            logging.debug("do enabled step: " + step_name)
            # Get function of this object which implements `step_name`.
            step_function = getattr(self, step_name)
            # Run the implementation.
            step_function()
        else:
            logging.debug("skip DISABLED state:" + step_name)

    ###########################################################################
    #
    def do_action(
        self,
    ):

        use_case = self.run_case
        assert(self.run_case is not None)
        logging.debug("use_case = '" + self.run_case + "'")

        for step_name in self.action_step_ordered_execution_list:
            self.do_action_wrapper(step_name)

###############################################################################
# EOF
###############################################################################

