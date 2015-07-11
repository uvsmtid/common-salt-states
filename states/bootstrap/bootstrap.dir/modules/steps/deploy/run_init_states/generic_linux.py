#

import sys
import logging

from utils.exec_command import call_subprocess
from utils.check_salt_output import process_string

###############################################################################
#
def run_states(state_names, salt_extra_args, cmd_extra_args):

    # Run `saltutil.sync_all` which is required to
    # get custom grains at least.
    # We don't try to analyse output.
    # If something is not synced yet, next `state.sls` should fail.
    process_output = call_subprocess(
        command_args = [
            'salt-call',
            '--out',
            'json',
            '--log-level',
            'debug',
        ] + salt_extra_args + [
            'saltutil.sync_all',
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

    for state_name in state_names:

        # The commands are run per minion - that's why `salt-call` is
        # used instead of `salt`.
        # The states should be designed so that they can determine themselves
        # whether they are applicable on this particular minion.
        process_output = call_subprocess(
            command_args = [
                'salt-call',
                '--out',
                'json',
                '--log-level',
                'debug',
            ] + salt_extra_args + [
                'state.sls',
                # NOTE:
                # Execute dummy state to satisfy minimum successful count = 1.
                # This is because at least `common.source_symlinks` in case of
                # online minion results in 0 states being executed.
                # We don't want to reduce minimum count to 0 because this
                # does not test state execution.
                str(state_name) + ',common.dummy',
                'test=False',
            ] + cmd_extra_args,
            raise_on_error = True,
            capture_stdout = True,
            capture_stderr = False,
        )

        # Print captured data for the record.
        sys.stderr.write(process_output["stdout"])

        logging.info("DONE: Salt execution completed and its output captured for analysis")

        # Check output results from `salt-call`.
        if not process_string(process_output["stdout"]):
            logging.critical("some Salt states failed")
            raise RuntimeError

###############################################################################
#
def do(action_context):

    # Explanation per use case:
    # * `initial-online-node` - it is assumed that Salt master is already
    #    accessible and `--local` is not required.
    # * `offline-minion-installer` - run with `--local` because it is
    #   standalone minon.
    salt_extra_args = []
    if action_context.run_use_case in [
        'offline-minion-installer'
    ]:
        salt_extra_args = [
            '--local',
        ]

    # Specify dinamically `bootstrap_mode` pillar key.
    cmd_extra_args = [
        'pillar={ \'bootstrap_mode\': \'' + action_context.run_use_case + '\' }',
    ]

    run_states(
        state_names = [
            'common.source_symlinks',
            'common.resource_symlinks',
        ],
        salt_extra_args = salt_extra_args,
        cmd_extra_args = cmd_extra_args,
    )

###############################################################################
# EOF
###############################################################################

