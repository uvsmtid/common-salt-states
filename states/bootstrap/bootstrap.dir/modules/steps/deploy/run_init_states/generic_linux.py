#

import sys
import logging

from utils.exec_command import call_subprocess
from utils.check_salt_output import process_string

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
        process_output = call_subprocess(
            command_args = [
                'salt-call',
                '--out',
                'json',
                '--log-level',
                'debug',
            ] + extra_args + [
                'state.sls',
                state_name,
                'test=False',
                # Specify dinamically `bootstrap_mode` pillar key.
                'pillar={ \'bootstrap_mode\': \'' + action_context.run_use_case + '\' }',
            ],
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
# EOF
###############################################################################

