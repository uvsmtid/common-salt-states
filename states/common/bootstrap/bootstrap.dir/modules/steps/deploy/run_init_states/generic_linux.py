#

from utils.exec_command import call_subprocess

###############################################################################
#
def do(action_context):

    # Explanation per use case:
    # * `initial-online-node` - it is assumed that Salt master is already
    #    accessible and `--local` is not required.
    # * `offline-minion-installer` - run with `--local` because it is
    #   standalone minon.
    extra_args = []
    if action_context.run_use_case in [
        'offline-minion-installer'
    ]:
        extra_args = [
            '--local',
        ]

    for state_name in [
        'common.source_symlinks',
        'common.resource_symlinks',
    ]:

        # The commands are run per minion - that's why `salt-call` is
        # used instead of `salt`.
        # The states should be designed so that they can determine themselves
        # whether they are applicable on this particular minion.
        call_subprocess(
            command_args = [
                'salt-call',
                '--log-level',
                'debug',
            ] + extra_args + [
                'state.sls',
                state_name,
                'test=False',
            ],
            raise_on_error = True,
            capture_stdout = False,
            capture_stderr = False,
        )
        # TODO: `salt-call` does not return non-zero error code when
        #        it fails. Something must be done to detect errors.

###############################################################################
# EOF
###############################################################################

