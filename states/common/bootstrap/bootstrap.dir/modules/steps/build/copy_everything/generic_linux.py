#

import logging
import os.path
import json

from utils.exec_command import call_subprocess

###############################################################################
#
def get_list_of_src_dst_path_pairs(
    action_context,
):
    src_dst_path_pairs = {}

    project_name = action_context.conf_m.project_name
    profile_name = action_context.conf_m.profile_name

    content_dir = os.path.join(
        action_context.content_dir,
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
                    action_context.content_dir,
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

    # Configuration files.
    src_dst_path_pairs['config'] = {
        'src': os.path.join(
                action_context.content_dir,
                'conf',
            ),
        'dst': os.path.join(
                content_dir,
                'conf',
            ),
    }


    # Source code for modules.
    src_dst_path_pairs['repos'] = {
        'src': os.path.join(
                action_context.content_dir,
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
                action_context.content_dir,
                'bootstrap.py',
            ),
        'dst': os.path.join(
                content_dir,
                'bootstrap.py',
            ),
    }

    # Make sure all paths are absolute.
    for path_pair in src_dst_path_pairs.values():
        assert(os.path.isabs(path_pair['src']))
        assert(os.path.isabs(path_pair['dst']))

    return src_dst_path_pairs

###############################################################################
#

def sync_src_dst_paths_pairs(
    src_dst_path_pairs,
):

    for path_pair in src_dst_path_pairs.values():

        # Make sure both paths have trailing slashes (`/`) if they
        # represent directory.
        for elem in ['src', 'dst']:
            if not os.path.exists(path_pair['src']):
                logging.critical("path does not exist: " + str(path_pair['src']))
                raise RuntimeError

            # Check source for path type, but modify both, if required.
            if os.path.isdir(path_pair['src']):
                if not path_pair[elem].endswith('/'):
                    path_pair[elem] = path_pair[elem] + '/'


        logging.info('src = ' + str(path_pair['src']))
        logging.info('dst = ' + str(path_pair['dst']))

        # Make sure basedir destination directory exists.
        call_subprocess(
            command_args = [
                'mkdir',
                '-p',
                os.path.dirname(
                    path_pair['dst'],
                ),
            ],
            raise_on_error = True,
            capture_stdout = False,
            capture_stderr = False,
        )

        call_subprocess(
            command_args = [
                'rsync',
                '--progress',
                '--recursive',
                '-v',
                path_pair['src'],
                path_pair['dst'],
            ],
            raise_on_error = True,
            capture_stdout = False,
            capture_stderr = False,
        )

###############################################################################
#

def do(action_context):

    src_dst_path_pairs = get_list_of_src_dst_path_pairs(action_context)
    logging.info('src_dst_path_pairs = ' + str(
            json.dumps(src_dst_path_pairs, sort_keys=True, indent=4)
        )
    )
    sync_src_dst_paths_pairs(src_dst_path_pairs)

###############################################################################
# EOF
###############################################################################

