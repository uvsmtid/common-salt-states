from platforms.generic_linux import generic_linux_deploy

###############################################################################
#
class rhel5_linux_deploy(generic_linux_deploy):

    def init_ip_route(
        self,
    ):
        from steps.deploy.init_ip_route.rhel5 import do
        do(self)

    def set_hostname(
        self,
    ):
        from steps.deploy.set_hostname.rhel5 import do
        do(self)

    def activate_salt_master(
        self,
    ):
        from steps.deploy.activate_salt_master.rhel5 import do
        do(self)

    def activate_salt_minion(
        self,
    ):
        from steps.deploy.activate_salt_minion.rhel5 import do
        do(self)

###############################################################################
#
def get_instance(
        run_dir,
        script_dir,
        base_dir,
        conf_m,
        run_action,
        run_use_case,
        target_env_conf,
    ):

        if run_action == 'deploy':
            return rhel5_linux_deploy(
                run_dir,
                script_dir,
                base_dir,
                conf_m,
                run_action,
                run_use_case,
                target_env_conf,
            )
        else:
            raise NotImplementedError

###############################################################################
# EOF
###############################################################################

