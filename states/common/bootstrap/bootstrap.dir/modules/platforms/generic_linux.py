from actions.deploy import deploy_template_method

class generic_linux_deploy(deploy_template_method):

    def init_ip_route(
        self,
    ):
        from steps.deploy.init_ip_route.generic_linux import do
        do(self)

    def init_dns_server(
        self,
    ):
        from steps.deploy.init_dns_server.generic_linux import do
        do(self)

    def make_salt_resolvable(
        self,
    ):
        from steps.deploy.make_salt_resolvable.generic_linux import do
        do(self)

    def init_yum_repos(
        self,
    ):
        from steps.deploy.init_yum_repos.generic_linux import do
        do(self)

    def install_salt_master(
        self,
    ):
        from steps.deploy.install_salt_master.generic_linux import do
        do(self)

    def install_salt_minion(
        self,
    ):
        from steps.deploy.install_salt_minion.generic_linux import do
        do(self)

    def activate_salt_master(
        self,
    ):
        # This method may depend on `initd` or `systemd` PID 1, for example.
        raise NotImplementedError

    def activate_salt_minion(
        self,
    ):
        # This method may depend on `initd` or `systemd` PID 1, for example.
        raise NotImplementedError

def get_instance(
        run_dir,
        script_dir,
        base_dir,
        conf_m,
        run_action,
        run_case,
        target_env,
    ):

        if run_action == 'deploy':
            return generic_linux_deploy(
                run_dir,
                script_dir,
                base_dir,
                conf_m,
                run_action,
                run_case,
                target_env,
            )
        else:
            raise NotImplementedError

