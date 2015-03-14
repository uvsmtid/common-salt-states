import logging

###############################################################################
#

class action_context:

    """
    Current working directory (CWD) where bootstrap was started from.

    This path is always absolute.
    """
    run_dir = None

    """
    Path to bootstrap script specified on command line.

    This path may be relative or absolute depending on the command line.
    """
    script_dir = None

    """
    Path to base directory with bootstrap script, configuration, resources.

    This path is always absolute.
    """
    base_dir = None

    """
    Configuration module loaded for bootstrap script.
    """
    conf_m = None

    """
    Name for action to execute.
    """
    run_action = None

    """
    Name for use case to execute.
    """
    run_use_case = None

    """
    Path to target enviroment configuration file for selected action.
    """
    target_env_conf = None

    ###########################################################################
    #

    """
    This dict maps action step to use case based on applicability.

    If action step is mapped into a list, it is only appliacable for the
    specified list of use cases.

    if action step is mapped to string "always", it is appliacable to
    all use cases.

    Anything else is error.

    The dict value is supposed to be set in the derived class.
    """
    action_step_to_use_case_map = None

    ###########################################################################
    #

    """
    Ordered list of step execution.

    Because lists are ordered in Python and dict keys are not, use this
    list to order the step execution.

    The list value is supposed to be set in the derived class.
    """
    action_step_ordered_execution_list = None

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
            if self.run_use_case not in self.action_step_to_use_case_map:
                logging.debug("skip not applicable step: " + step_name)
                return
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
    def __init__(
        self,
        run_dir,
        script_dir,
        base_dir,
        conf_m,
        run_action,
        run_use_case,
        target_env_conf,
    ):
        self.run_dir = run_dir
        self.script_dir = script_dir
        self.base_dir = base_dir
        self.conf_m = conf_m
        self.run_action = run_action
        self.run_use_case = run_use_case
        self.target_env_conf = target_env_conf

        logging.info("run_dir = " + str(self.run_dir))
        logging.info("script_dir = " + str(self.script_dir))
        logging.info("base_dir = " + str(self.base_dir))
        logging.info("conf_m = " + str(self.conf_m))
        logging.info("run_action = " + self.run_action)
        logging.info("run_use_case = " + self.run_use_case)
        logging.info("target_env_conf = " + self.target_env_conf)

    ###########################################################################
    #
    def do_action(
        self,
    ):

        use_case = self.run_use_case
        assert(self.run_use_case is not None)
        logging.debug("use_case = '" + self.run_use_case + "'")

        for step_name in self.action_step_ordered_execution_list:
            self.do_action_wrapper(step_name)

################################################################################
# EOF
###############################################################################

