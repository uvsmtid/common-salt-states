
###############################################################################

import logging

from utils.set_network import ping_host_windows

###############################################################################
#

def do(action_context):

    # NOTE: Run exactly the same procedure on Windows with Cygwin.
    #       Modification of `/etc/hosts` on Cygwin actually modifies
    #       appropriate Windows hosts file.
    from steps.deploy.make_salt_resolvable.generic_linux import update_hosts_file
    update_hosts_file(action_context)

    # Make sure `salt` hosts are ping-able.
    ping_host_windows(
        resolvable_string = 'salt',
    )

###############################################################################
# EOF
###############################################################################

