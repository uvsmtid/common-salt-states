#!py

#
# This is a pure Python renderer.
# See also:
#    http://docs.saltstack.com/en/latest/ref/renderers/all/salt.renderers.py.html
#

import os

hash_type_to_command_map = {
    "md5": "md5sum",
    "sha1": "sha1sum",
    "sha224": "sha224sum",
    "sha256": "sha256sum",
    "sha384": "sha384sum",
    "sha512": "sha512sum",
}

def run():

    sls_config = {}

    # Make sure the content validation feature is enabled.
    if not __pillar__['system_features']['validate_depository_content']['feature_enabled']:
        return sls_config

    # Make sure it is `depository-role`.
    if not __grains__['id'] in __pillar__['system_host_roles']['depository-role']['assigned_hosts']:
        return sls_config

    script_name = 'check_content.sh'
    depository_content_parent_dir = __pillar__['system_features']['validate_depository_content']['depository_content_parent_dir']
    posix_config_temp_dir = __pillar__['posix_config_temp_dir']

    # First, deploy the script.
    script_path = os.path.join(
        posix_config_temp_dir,
        script_name,
    )
    deploy_script = {
        'file.managed': [
            { 'name': script_path },
            { 'source': 'salt://common/webserver/depository-role/' + script_name },
            { 'user': 'root' },
            { 'group': 'root' },
            { 'mode': '755' },
            { 'makedirs': True },
        ]
    }
    sls_config[script_path] = deploy_script


    # Then, add all content items to verify checksums.
    for content_item_name in __pillar__['registered_content_items'].keys():
        content_item = __pillar__['registered_content_items'][content_item_name]
        if content_item['enable_content_validation']:
            hash_fields = content_item['item_content_hash'].split('=')
            hash_type = hash_fields[0]
            hash_value = hash_fields[1]

            sls_item_config = {
                'cmd.run': [
                    {
                        'name': (
                            script_path +
                            ' ' +
                            hash_type_to_command_map[hash_type] +
                            ' ' +
                            os.path.join(
                                depository_content_parent_dir,
                                content_item['item_parent_dir_path'],
                                content_item['item_base_name'],
                            ) +
                            ' ' +
                            hash_value
                        ),
                    },
                    {
                        'require': [
                            {
                                'file': script_path,
                            },
                        ],
                    },
                ],
            }

            sls_config[content_item_name] = sls_item_config

    return sls_config

