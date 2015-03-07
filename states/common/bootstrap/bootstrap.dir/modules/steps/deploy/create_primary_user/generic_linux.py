import os

###############################################################################
#

def do(action_context):

    # Note that there is no intention to add password for this user.
    # The only reason why this user is created is to put sources under
    # its home directory.
    os.system("/usr/sbin/groupadd " + action_context.conf_m.create_primary_user['primary_group'])
    os.system("/usr/sbin/useradd " + action_context.conf_m.create_primary_user['primary_user'] + " --gid " + action_context.conf_m.create_primary_user['primary_group'])

###############################################################################
# EOF
###############################################################################

