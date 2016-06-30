# This states deploys script which syncs
# local_mirrors on its local storage with Internet and local repos server:
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

{% for repo_name in pillar['system_features']['yum_repos_configuration']['yum_repositories'].keys() %}
{% for os_platform in pillar['system_features']['yum_repos_configuration']['yum_repositories'][repo_name]['os_platform_configs'].keys() %}
{% set repo_config = pillar['system_features']['yum_repos_configuration']['yum_repositories'][repo_name]['os_platform_configs'][os_platform] %}

{% if 'rsync_mirror_internet_source_base_url' in repo_config and 'rsync_mirror_internet_source_rel_path' in repo_config %}

{% set base_dir = config_temp_dir + '/' + pillar['system_features']['yum_repos_configuration']['rsync_syncer_base_dir'] + '/config/' + repo_name + '/' + os_platform %}

rsync_mirror_source_{{ repo_name }}_{{ os_platform }}:
    file.managed:
        - name: '{{ base_dir }}/rsync_mirror_source'
        - makedirs: True
        # NOTE: Concatenation has not `/`.
        #       Both URL parts should concatenate without `/` by convention.
        - contents: '{{ repo_config['rsync_mirror_internet_source_base_url'] }}{{ repo_config['rsync_mirror_internet_source_rel_path'] }}'
        - user: '{{ account_conf['username'] }}'
        - group: '{{ account_conf['primary_group'] }}'
        - mode: 644
        - template: jinja

rsync_mirror_internet_source_base_url_{{ repo_name }}_{{ os_platform }}:
    file.managed:
        - name: '{{ base_dir }}/rsync_mirror_internet_source_base_url'
        - makedirs: True
        - contents: '{{ repo_config['rsync_mirror_internet_source_base_url'] }}'
        - user: '{{ account_conf['username'] }}'
        - group: '{{ account_conf['primary_group'] }}'
        - mode: 644
        - template: jinja

rsync_mirror_internet_source_rel_path_{{ repo_name }}_{{ os_platform }}:
    file.managed:
        - name: '{{ base_dir }}/rsync_mirror_internet_source_rel_path'
        - makedirs: True
        - contents: '{{ repo_config['rsync_mirror_internet_source_rel_path'] }}'
        - user: '{{ account_conf['username'] }}'
        - group: '{{ account_conf['primary_group'] }}'
        - mode: 644
        - template: jinja

{% endif %}

{% endfor %}
{% endfor %}

{% set base_dir = config_temp_dir + '/' + pillar['system_features']['yum_repos_configuration']['rsync_syncer_base_dir'] %}

deploy_script_rsync_local_mirrors.sh:
    file.managed:
        - source: 'salt://common/yum/local_mirrors/rsync_local_mirrors.sh.sls'
        - template: jinja
        - name: '{{ base_dir }}/rsync_local_mirrors.sh'
        - makedirs: True
        - user: '{{ account_conf['username'] }}'
        - group: '{{ account_conf['primary_group'] }}'
        - mode: 755

{% endif %} # os_platform_type
# ]]]
###############################################################################

