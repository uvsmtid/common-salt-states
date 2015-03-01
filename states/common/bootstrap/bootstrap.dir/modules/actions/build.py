
class build_template_method:

    conf_m = None
    run_action = None
    run_case = None
    target_env = None

    def __init__(
        self,
        conf_m,
        run_action,
        run_case,
        target_env,
    ):
        self.conf_m = conf_m
        self.run_action = run_action
        self.run_case = run_case
        self.target_env = target_env

    def do_action(
        self,
    ):
        print "NOT IMPLEMENTED"
        return

