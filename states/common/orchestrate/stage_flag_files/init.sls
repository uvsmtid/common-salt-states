# Prepare stage flag files directory.

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS' ] %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Fedora' ] %}

{% if grains['id'] in pillar['system_host_roles']['controller-role']['assigned_hosts'] %}

{% set controller_role_host = pillar['system_hosts'][pillar['system_host_roles']['controller-role']['assigned_hosts'][0]] %}

{% set dir_name = controller_role_host['primary_user']['posix_user_home_dir'] + '/' + pillar['system_orchestrate_stages']['deployment_directory_path'] %}

'{{ dir_name }}':
    file.directory:
        - makedirs: True

{% endif %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

{% endif %}
# >>>
###############################################################################


