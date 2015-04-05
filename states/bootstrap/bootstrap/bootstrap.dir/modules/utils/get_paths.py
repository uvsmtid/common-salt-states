import os.path

###############################################################################
#

def get_abs_path(
    content_dir,
    item_path,
):
    if os.path.isabs(item_path):
        return item_path
    else:
        return os.path.join(
            content_dir,
            item_path,
        )

###############################################################################
# EOF
###############################################################################

