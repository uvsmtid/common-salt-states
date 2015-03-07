import os
from utils.hosts_file import do_patch
from utils.hosts_file import do_diff
from utils.exec_command import call_subprocess

###############################################################################
#
def do(action_context):

    # File with source entries for `hosts` file.
    src_path = os.path.join(
        action_context.base_dir,
        action_context.conf_m.make_salt_resolvable['required_entries_hosts_file'],
    )

    # File destination for `hosts` file entries (hosts file itself).
    dst_path = '/etc/hosts'

    # Make sure there is no `salt` hostname mapped to different IP address.
    result = do_diff(
        src_path = src_path,
        dst_path = dst_path,
        # We don't care about missing - they will be added.
        check_missing = False,
        # We don't care about unexpected - let them be there.
        check_unexpected = False,
        # We DO care when `salt` hostname is already set to
        # something different than what we want.
        check_modified = True,
    )
    if result:
        raise RuntimeError

    # Patch file with missing entries.
    # It won't overwrite existing ones,
    # but patch is not done if there are existing ones.
    do_patch(
        src_path = src_path,
        dst_path = dst_path,
    )

    # Make sure `salt` hosts are ping-able.
    call_subprocess(
        command_args = [
            'ping',
            '-c',
            '3',
            'salt',
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
# EOF
###############################################################################

