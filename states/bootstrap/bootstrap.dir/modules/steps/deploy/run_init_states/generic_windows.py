#

###############################################################################
#

def do(action_context):

    from steps.deploy.run_init_states.generic_linux import run_init_states

    run_init_states(
        action_context.run_use_case,
        salt_extra_args = [],
        cmd_extra_args = [],
        extra_state_names = [],
        # NOTE; All ww need for Windows it to point to
        #       Cygwin path to `salt-call.bat`.
        salt_call_path = '/cygdrive/c/salt/salt-call.bat',
    )

###############################################################################
# EOF
###############################################################################

