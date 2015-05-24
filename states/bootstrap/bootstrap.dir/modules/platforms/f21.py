from platforms.generic_linux import generic_linux_build

###############################################################################
#

class fc21_linux_build(generic_linux_build):
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
        elif run_action == 'build':
            return fc21_linux_build(
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

