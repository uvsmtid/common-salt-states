#!/usr/bin/env python

# The script verifies checksum of registered content.
# TODO: Add support of multiple repositories for registered content.
#       At the moment it fails as content is saved in different locations.
# NOTE: The script has to run in its parent directory
#       where shell script for check sum verification is located.

# Standard modules.
import os
import sys
import logging
import subprocess

# Without this line `salt.client` somehow prevents all subsequent output.
logging.debug('initilize logging')

# Salt modules.
import salt.client

hash_type_to_command_map = {
    "md5": "md5sum",
    "sha1": "sha1sum",
    "sha224": "sha224sum",
    "sha256": "sha256sum",
    "sha384": "sha384sum",
    "sha512": "sha512sum",
}

################################################################################
#

def setLoggingLevel(
    level_name = None,
):

    # Set log level ahead of the processing
    num_level = getattr(logging, level_name.upper(), None)
    if not isinstance(num_level, int):
        raise ValueError('error: invalid log level \"%s\"' % level_name)
    logging.getLogger().setLevel(num_level)

################################################################################
# MAIN

# Set logging level.
setLoggingLevel('debug')

# Final exit code.
exit_code = 0

# Get subcommand.
subcommand = sys.argv[1]
logging.info('subcommand: ' + str(subcommand))

caller = salt.client.Caller()
logging.debug(str(caller))

pillar = caller.function('pillar.items')
logging.debug(str(pillar))

# TODO: At the moment script uses only single resource repository.
#       Refactor together with concept of repository to verify everything.
content_parent_dir = pillar['system_features']['resource_repositories_configuration']['resource_respositories']['common-resources']['abs_resource_target_path']
logging.debug('content_parent_dir: ' + str(content_parent_dir))

script_name = './check_content.sh'
script_path = os.path.join(
    script_name,
)
logging.debug('script_path: ' + str(script_path))

# Prepare content items in an intermediate dict: { path: { hash_type, hash_value } }.
registered_content = {}
logging.debug('system_resources/keys: ' + str(pillar['system_resources'].keys()))
for content_item_name in pillar['system_resources'].keys():
    content_item = pillar['system_resources'][content_item_name]
    if content_item['enable_content_validation']:
        hash_fields = content_item['item_content_hash'].split('=')
        hash_type = hash_fields[0]
        hash_value = hash_fields[1]

        registered_content [
            os.path.join(
                content_parent_dir,
                content_item['item_parent_dir_path'],
                content_item['item_base_name'],
            )
        ] = {
            'hash_type': hash_type,
            'hash_value': hash_value,
            'found': False,
        }
logging.debug('registered_content: ' + str(registered_content))

# Go through each and every file under `content_parent_dir`.
for (dirpath, dirnames, filenames) in os.walk(content_parent_dir, followlinks = False):
    for filename in filenames:
        item_path = os.path.join(dirpath, filename)
        if item_path in registered_content.keys():
            registered_content[item_path]['found'] = True
            if content_parent_dir in item_path:
                print 'CHECK CONTENT: ' + item_path
                result = os.system(
                    script_path + ' ' +
                    hash_type_to_command_map[registered_content[item_path]['hash_type']] + ' ' +
                    item_path + ' ' +
                    registered_content[item_path]['hash_value']
                )
                if result != 0:
                    exit_code = 1
                    print 'FAILURE'
                else:
                    print 'SUCCESS'
            else:
                print 'OUT OF SCOPE: ' + item_path
        else:
            if content_parent_dir in item_path:
                # Report about unregistered when in scope.
                print 'SKIP UNREGISTERED: ' + item_path
            else:
                # Ignore completely when unregistered and out of scope.
                pass

# List all files under parent dir which hasn't been found.
for item_path in registered_content.keys():
    if content_parent_dir in item_path:
        if not registered_content[item_path]['found']:
            exit_code = 1
            print 'NOT FOUND: ' + item_path

# Report result.
sys.exit(exit_code)

