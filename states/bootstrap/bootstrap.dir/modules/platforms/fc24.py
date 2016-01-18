from platforms.generic_linux import generic_linux_build

###############################################################################
#

# TODO: Fedora is fast-moving distribution.
#       The code gets duplicated for `fc22`, `fc23`, `fc24`, ...
#       Propose solution to reuse the code.
class fc24_linux_build(generic_linux_build):
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
            return fc24_linux_build(
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

