# This states deploys script which syncs
# local_yum_mirrors on its local storage with Internet and local repos server:
# Internet => syncer local storage => repos server.
#
# There is no special role designated for syncer - it can be any host
# which happens to have (sometimes) access to both Internet and repos server.
#

{% if grains['kernel'] == 'Linux' %}
{% set config_temp_dir = pillar['posix_config_temp_dir'] %}
{% endif %}
{% if grains['kernel'] == 'Windows' %}
{% set config_temp_dir = pillar['windows_config_temp_dir'] %}
{% endif %}

###############################################################################
# [[[ Any Linux
{% if not grains['os_platform_type'].startswith('win') %}

{% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
{% set user_home_dir = account_conf['posix_user_home_dir'] %}

{% set base_dir = pillar['system_features']['yum_repos_configuration']['local_yum_mirrors_role_content_dir'] %}

deploy_script_rsync_local_yum_mirrors.sh:
    file.managed:
        - source: 'salt://common/yum/local_yum_mirrors_role/rsync_local_yum_mirrors.sh.sls'
        - template: jinja
        - name: '{{ base_dir }}/rsync_local_yum_mirrors.sh'
        - makedirs: True
        - user: '{{ account_conf['username'] }}'
        - group: '{{ account_conf['primary_group'] }}'
        - mode: 755

{% endif %} # os_platform_type
# ]]]
###############################################################################

