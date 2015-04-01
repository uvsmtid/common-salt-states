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

{% if grains['id'] in pillar['system_host_roles']['controller_role']['assigned_hosts'] %}

{% set dir_name = control_host['primary_user']['posix_user_home_dir'] + '/' + pillar['orchestration_stages']['deployment_directory_path'] %}

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


