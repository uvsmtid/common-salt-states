
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

        print "run_dir = " + str(self.run_dir)
        print "script_dir = " + str(self.script_dir)
        print "base_dir = " + str(self.base_dir)
        print "conf_m = " + str(self.conf_m)
        print "run_action = " + self.run_action
        print "run_case = " + self.run_case
        print "target_env = " + self.target_env

