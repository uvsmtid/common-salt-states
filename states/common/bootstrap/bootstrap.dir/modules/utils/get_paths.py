import os.path

###############################################################################
#

def get_abs_path(
    base_dir,
    item_path,
):
    if os.path.isabs(item_path):
        return item_path
    else:
        return os.path.join(
            base_dir,
            item_path,
        )

###############################################################################

