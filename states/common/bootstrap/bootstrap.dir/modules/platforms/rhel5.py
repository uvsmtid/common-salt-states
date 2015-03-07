from platforms.generic_linux import generic_linux_deploy

###############################################################################
#
class rhel5_linux_deploy(generic_linux_deploy):

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
        run_case,
        target_env,
    ):

        if run_action == 'deploy':
            return rhel5_linux_deploy(
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

###############################################################################
# EOF
###############################################################################

