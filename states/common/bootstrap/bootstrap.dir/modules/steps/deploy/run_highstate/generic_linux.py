#

import sys

from utils.exec_command import call_subprocess
from utils.salt_output import load_yaml_string_data
from utils.salt_output import check_result

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

    if True:
        # The commands are run per minion - that's why `salt-call` is
        # used instead of `salt`.
        # The states should be designed so that they can determine themselves
        # whether they are applicable on this particular minion.
        process_output = call_subprocess(
            command_args = [
                'salt-call',
                '--out',
                'yaml',
                '--log-level',
                'debug',
            ] + extra_args + [
                'state.highstate',
                'test=False',
            ],
            raise_on_error = True,
            capture_stdout = True,
            capture_stderr = False,
        )

        # Print captured data for the record.
        sys.stderr.write(process_output["stdout"])

        # Check output results from `salt-call`.
        loaded_data = load_yaml_string_data(process_output["stdout"])
        if not check_result(loaded_data):
            raise RuntimeError

###############################################################################
# EOF
###############################################################################

