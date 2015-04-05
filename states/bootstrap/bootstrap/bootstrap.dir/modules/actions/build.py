#

import logging

from context import action_context

###############################################################################
#
class build_template_method (action_context):

    ###########################################################################
    # See base class for pythondoc.

    action_step_to_use_case_map = {

        "copy_everything": "always",

        "pack_everything": "always",

    }

    ###########################################################################
    # See base class for pythondoc.

    action_step_ordered_execution_list = [
        "copy_everything",
        "pack_everything",
    ]


###############################################################################
# EOF
###############################################################################

