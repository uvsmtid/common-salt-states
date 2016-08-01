
###############################################################################

import os.path

from utils.hosts_file import do_patch
from utils.hosts_file import do_diff
from utils.exec_command import call_subprocess
from utils.set_network import ping_host_linux

###############################################################################
#

def update_hosts_file(action_context):

    # File with source entries for `hosts` file.
    src_path = os.path.join(
        action_context.content_dir,
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
    # Result if False when there is not difference.
    if result:
        raise RuntimeError

    # Patch file with missing entries.
    # It won't overwrite existing ones,
    # but patch is not done if there are existing ones.
    do_patch(
        src_path = src_path,
        dst_path = dst_path,
    )

###############################################################################
#

def do(action_context):

    update_hosts_file(action_context)

    # Make sure `salt` hosts are ping-able.
    ping_host_linux(
        resolvable_string = 'salt',
    )

###############################################################################
# EOF
###############################################################################

