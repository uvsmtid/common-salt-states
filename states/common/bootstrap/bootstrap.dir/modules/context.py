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
    run_case = None

    """
    Name of target enviroment for selected action.
    """
    target_env = None

    def __init__(
        self,
        run_dir,
        script_dir,
        base_dir,
        conf_m,
        run_action,
        run_case,
        target_env,
    ):
        self.run_dir = run_dir
        self.script_dir = script_dir
        self.base_dir = base_dir
        self.conf_m = conf_m
        self.run_action = run_action
        self.run_case = run_case
        self.target_env = target_env

        logging.info("run_dir = " + str(self.run_dir))
        logging.info("script_dir = " + str(self.script_dir))
        logging.info("base_dir = " + str(self.base_dir))
        logging.info("conf_m = " + str(self.conf_m))
        logging.info("run_action = " + self.run_action)
        logging.info("run_case = " + self.run_case)
        logging.info("target_env = " + self.target_env)

################################################################################
# EOF
###############################################################################

