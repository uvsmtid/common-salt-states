from actions.deploy import deploy_template_method

class generic_linux_deploy(deploy_template_method):

    def init_ip_route(
        self,
    ):
        from steps.deploy.init_ip_route.generic_linux import do
        do(self.conf_m.init_ip_route)

    def init_dns_server(
        self,
    ):
        from steps.deploy.init_dns_server.generic_linux import do
        do(self.conf_m.init_dns_server)

    def init_yum_repos(
        self,
    ):
        from steps.deploy.init_yum_repos.generic_linux import do
        do(self.conf_m.init_yum_repos)

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

