
###############################################################################

###############################################################################
#

def do(action_context):

    # NOTE: Skip for non-master minions.
    if not action_context.conf_m.activate_salt_master['is_salt_master']:
        return

    # Windows cannot be Salt master. 
    logging.critical("Windows cannot be salt master.")
    raise NotImplementedError

###############################################################################
# EOF
###############################################################################

