# Prepare stage flag files directory.

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel5') %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel7') or grains['os_platform_type'].startswith('fc') %}

{% if grains['id'] in pillar['system_host_roles']['salt_master_role']['assigned_hosts'] %}

{% set salt_master_role_host = pillar['system_hosts'][pillar['system_host_roles']['salt_master_role']['assigned_hosts'][0]] %}

{% set account_conf = pillar['system_accounts'][ salt_master_role_host['primary_user'] ] %}
{% set dir_name = account_conf['posix_user_home_dir'] + '/' + pillar['system_orchestrate_stages']['deployment_directory_path'] %}

'{{ dir_name }}':
    file.directory:
        - makedirs: True

{% endif %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

{% endif %}
# >>>
###############################################################################


