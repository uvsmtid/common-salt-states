# Deploy wildfly distribution.

# The state deploys a number of wildfly distributions
# using configuration data specified in pillar:
#   * resource id for wildfly distribution archive
#   * destination deployment directory

# TODO: Create configured instances for deployments.

###############################################################################
# [[[[[
{% if grains['os_platform_type'].startswith('fc') or grains['os_platform_type'].startswith('rhel7') %}

{% set resources_macro_lib = 'common/resource_symlinks/resources_macro_lib.sls' %}
{% from resources_macro_lib import get_registered_content_item_URI with context %}
{% from resources_macro_lib import get_registered_content_item_hash with context %}

# Loop through instances and check if they are applicable for this minion.
{% for instance_id in pillar['system_features']['wildfly_instances'].keys() %} # wildfly_instances

{% set instance_config = pillar['system_features']['wildfly_instances'][instance_id] %}

# Check if minion is assigned for the `target_system_role`.
{% if grains['id'] in pillar['system_host_roles'][ instance_config['target_system_role'] ]['assigned_hosts'] %} # target_system_role

{% set deployment_id = instance_config['deployment_id'] %}
{% set deployment_config = pillar['system_features']['wildfly_deployments'][deployment_id] %}

{% set account_conf = pillar['system_accounts'][ deployment_config['owner_user'] ] %}
{% set user_home_dir = account_conf['posix_user_home_dir'] %}

{% set resource_id = deployment_config['resource_id'] %}
{% set destination_dir_path = deployment_config['destination_dir_path'] %}
{% set archive_format = deployment_config['archive_format'] %}
{% set root_subdir = deployment_config['root_subdir'] %}
# If path is relative, it is relative to user home.
{% if not destination_dir_path.startswith('/') %}
{% set destination_dir_path = user_home_dir + '/' + deployment_config['destination_dir_path'] %}
{% endif %}

# Deploy wildfly first.
# NOTE: It is not re-deployed again to avoid destroying previously
#       configured instances. If re-deployment is required,
#       remove path which is used to check whether deployment exists.

'extract_wildfly_distribution_archive_{{ deployment_id }}_{{ instance_id }}':
    archive.extracted:
        - name: '{{ destination_dir_path }}'
        - source: {{ get_registered_content_item_URI(resource_id) }}
        - source_hash: {{ get_registered_content_item_hash(resource_id) }}
        - archive_format: '{{ archive_format }}'
        - archive_user: '{{ account_conf['username'] }}'
        # Do not overwrite existing directory.
        - unless: 'ls {{ destination_dir_path }}'

'wildfly_distribution_permissions_{{ deployment_id }}_{{ instance_id }}':
    file.directory:
        - name: '{{ destination_dir_path }}'
        - source: ~
        - user: '{{ account_conf['username'] }}'
        - group: '{{ account_conf['primary_group'] }}'
        - recurse:
            - user
            - group
        - require:
            - archive: 'extract_wildfly_distribution_archive_{{ deployment_id }}_{{ instance_id }}'

# NOTE: Unfortunately, `archive.extracted` clears executable permissions
#       on files originally set in archive.
'fix_executable_permissions_{{ deployment_id }}_{{ instance_id }}':
    cmd.run:
        - name: 'find {{ destination_dir_path }} -name "*.sh" -exec chmod u+x {} \;'
        - require:
            - file: 'wildfly_distribution_permissions_{{ deployment_id }}_{{ instance_id }}'

# Create instances within deployed archive.
'clone_wildfly_instance_{{ deployment_id }}_{{ instance_id }}':
    cmd.run:
        - name: 'cp -rp {{ destination_dir_path }}/{{ root_subdir }}/standalone {{ destination_dir_path }}/{{ root_subdir }}/{{ instance_id }}'
        # Do not overwrite existing directory.
        - unless: 'ls {{ destination_dir_path }}/{{ root_subdir }}/{{ instance_id }}'
        - require:
            - file: 'wildfly_distribution_permissions_{{ deployment_id }}_{{ instance_id }}'

# Deploy each template.
{% for template_id in instance_config['file_templates'].keys() %} # template_id

{% set template_config = instance_config['file_templates'][template_id] %}

'deploy_instance_template_{{ deployment_id }}_{{ instance_id }}_{{ template_id }}':
    file.managed:
        - name: '{{ destination_dir_path }}/{{ root_subdir }}/{{ instance_id }}/{{ template_config['destination_path'] }}'
        - source: '{{ template_config['source_url'] }}'
        - template: '{{ template_config['template_type'] }}'
        - context:
        # The value of `config_data` is not a string, it is data.
            config_data: {{ template_config['config_data']|json }}

{% endfor %} # template_id

{% endif %} # target_system_role

{% endfor %} # wildfly_instances

{% endif %}
# ]]]]]
###############################################################################

