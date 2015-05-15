#!/usr/bin/python

# Standard modules.
import os
import sys
import subprocess

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

# Final exit code.
exit_code = 0

# Get parent directory.
parent_dir = sys.argv[1]
print 'parent_dir: ' + str(parent_dir)

# Get subcommand.
subcommand = sys.argv[1]
print 'subcommand: ' + str(subcommand)

caller = salt.client.Caller()

pillar = caller.function('pillar.items')

depository_content_parent_dir = pillar['system_features']['validate_depository_content']['depository_content_parent_dir']
posix_config_temp_dir = pillar['posix_config_temp_dir']
script_name = 'check_content.sh'

script_path = os.path.join(
    posix_config_temp_dir,
    script_name,
)

# Prepare content items in an intermediate dict: { path: { hash_type, hash_value } }.
registered_content = {}
for content_item_name in pillar['system_resources'].keys():
    content_item = pillar['system_resources'][content_item_name]
    if content_item['enable_content_validation']:
        hash_fields = content_item['item_content_hash'].split('=')
        hash_type = hash_fields[0]
        hash_value = hash_fields[1]

        registered_content [
            os.path.join(
                depository_content_parent_dir,
                content_item['item_parent_dir_path'],
                content_item['item_base_name'],
            )
        ] = {
            'hash_type': hash_type,
            'hash_value': hash_value,
            'found': False,
        }

# Go through each and every file under `depository_content_parent_dir`.
for (dirpath, dirnames, filenames) in os.walk(depository_content_parent_dir, followlinks = False):
    for filename in filenames:
        item_path = os.path.join(dirpath, filename)
        if item_path in registered_content.keys():
            registered_content[item_path]['found'] = True
            if parent_dir in item_path:
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
            if parent_dir in item_path:
                # Report about unregistered when in scope.
                print 'SKIP UNREGISTERED: ' + item_path
            else:
                # Ignore completely when unregistered and out of scope.
                pass

# List all files under parent dir which hasn't been found.
for item_path in registered_content.keys():
    if parent_dir in item_path:
        if not registered_content[item_path]['found']:
            exit_code = 1
            print 'NOT FOUND: ' + item_path

# Report result.
sys.exit(exit_code)

