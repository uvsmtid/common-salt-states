from actions.deploy import deploy_template_method

class generic_linux_deploy(deploy_template_method):

    def init_ip_route(
        self,
    ):
        print "conf_m = " + str(self.conf_m)
        print "run_action = " + self.run_action
        print "run_case = " + self.run_case
        print "target_env = " + self.target_env

        from steps.init_ip_route.generic_linux import do
        do(self.conf_m.init_ip_route)

def get_instance(
        conf_m,
        run_action,
        run_case,
        target_env,
    ):

        if run_action == 'deploy':
            return generic_linux_deploy(
                conf_m,
                run_action,
                run_case,
                target_env,
            )
        else:
            raise NotImplementedError

