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

################################################################################
# EOF
###############################################################################

