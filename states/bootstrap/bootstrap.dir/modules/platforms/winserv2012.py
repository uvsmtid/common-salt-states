from platforms.generic_windows import generic_windows_deploy
from platforms.generic_windows import generic_windows_build

###############################################################################
#

class winserv2012_windows_deploy(generic_windows_deploy):
    pass

###############################################################################
#

class winserv2012_windows_build(generic_windows_build):
    pass

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
            return winserv2012_windows_deploy(
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
            return winserv2012_windows_build(
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

