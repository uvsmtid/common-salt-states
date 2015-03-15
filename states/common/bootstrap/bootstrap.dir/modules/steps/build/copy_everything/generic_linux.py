#

import logging
import os.path
import json

###############################################################################
#
def get_list_of_src_dst_path_pairs(
    action_context,
):
    src_dst_path_pairs = {}

    project_name = action_context.conf_m.project_name
    profile_name = action_context.conf_m.profile_name

    content_dir = os.path.join(
        action_context.base_dir,
        'packages',
        project_name,
        profile_name,
        'content',
    )

    # Resources.
    for resource_type in [
        'conf',
        'depository',
        'bootstrap',
        'rewritten_pillars',
        'sources',
    ]:
        src_dst_path_pairs[resource_type] = {
            'src': os.path.join(
                    action_context.base_dir,
                    'resources',
                    resource_type,
                    project_name,
                    profile_name,
                ),
            'dst': os.path.join(
                    content_dir,
                    'resources',
                    resource_type,
                    project_name,
                    profile_name,
                ),
        }

    # Source code for modules.
    src_dst_path_pairs['sources'] = {
        'src': os.path.join(
                action_context.base_dir,
                'modules',
            ),
        'dst': os.path.join(
                content_dir,
                'modules',
            ),
    }

    # Main script file.
    src_dst_path_pairs['script'] = {
        'src': os.path.join(
                action_context.base_dir,
                'bootstrap.py',
            ),
        'dst': os.path.join(
                content_dir,
                'bootstrap.py',
            ),
    }

    return src_dst_path_pairs

###############################################################################
#

def do(action_context):

    src_dst_path_pairs = get_list_of_src_dst_path_pairs(action_context)
    logging.info('src_dst_path_pairs = ' + str(
            json.dumps(src_dst_path_pairs, sort_keys=True, indent=4)
        )
    )
    logging.critical('NOT IMPLEMENTED')

###############################################################################
# EOF
###############################################################################

