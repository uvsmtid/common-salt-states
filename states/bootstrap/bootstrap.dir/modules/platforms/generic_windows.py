
import logging

from actions.deploy import deploy_template_method
from actions.build import build_template_method

###############################################################################
#

class generic_windows_deploy(deploy_template_method):

    def init_ip_route(
        self,
    ):

        # TODO: Implement for Windows.
        logging.critical("Implement for Windows: init_ip_route")
        return

        # This method may depend on location and format of configuration files.
        raise NotImplementedError

    def init_dns_server(
        self,
    ):
        from steps.deploy.init_dns_server.generic_windows import do
        do(self)

    def make_salt_resolvable(
        self,
    ):
        from steps.deploy.make_salt_resolvable.generic_windows import do
        do(self)

    def set_hostname(
        self,
    ):
        from steps.deploy.set_hostname.generic_windows import do
        do(self)

    def create_primary_user(
        self,
    ):
        from steps.deploy.create_primary_user.generic_windows import do
        do(self)

    def init_yum_repos(
        self,
    ):
        from steps.deploy.init_yum_repos.generic_windows import do
        do(self)

    def install_salt_master(
        self,
    ):
        from steps.deploy.install_salt_master.generic_windows import do
        do(self)

    def install_salt_minion(
        self,
    ):
        from steps.deploy.install_salt_minion.generic_windows import do
        do(self)

    def link_sources(
        self,
    ):
        from steps.deploy.link_sources.generic_windows import do
        do(self)

    def link_resources(
        self,
    ):
        from steps.deploy.link_resources.generic_windows import do
        do(self)

    def activate_salt_master(
        self,
    ):

        from steps.deploy.activate_salt_master.generic_windows import do
        do(self)

    def activate_salt_minion(
        self,
    ):

        # This method may depend on `initd` or `systemd` PID 1, for example.
        raise NotImplementedError

    def run_init_states(
        self,
    ):
        from steps.deploy.run_init_states.generic_windows import do
        do(self)

    def run_highstate(
        self,
    ):
        from steps.deploy.run_highstate.generic_windows import do
        do(self)

###############################################################################
#

class generic_windows_build(build_template_method):

    def copy_everything(
        self,
    ):
        from steps.build.copy_everything.generic_windows import do
        do(self)

    def pack_everything(
        self,
    ):
        # Pack everything. Yeah!
        from steps.build.pack_everything.generic_windows import do
        do(self)

###############################################################################
#

def get_instance(
        run_dir,
        script_dir,
        content_dir,
        modules_dir,
        conf_m,
        run_action,
        run_use_case,
        target_env_conf,
    ):

        if run_action is None:
            raise RuntimeError
        elif run_action == 'deploy':
            return generic_windows_deploy(
                run_dir,
                script_dir,
                content_dir,
                modules_dir,
                conf_m,
                run_action,
                run_use_case,
                target_env_conf,
            )
        elif run_action == 'build':
            return generic_windows_build(
                run_dir,
                script_dir,
                content_dir,
                modules_dir,
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

