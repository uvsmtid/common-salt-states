#

###############################################################################
# <<<
{% if grains['os'] in [ 'Fedora' ] %}

{% set user_home_dir = pillar['system_hosts'][grains['id']]['primary_user']['posix_user_home_dir'] %}
{% set vagrant_dir = user_home_dir + '/' + pillar['system_features']['vagrant_configuration']['vagrant_file_dir'] %}

{% set use_symlink_for_bootstrap_dir = pillar['system_features']['use_symlink_for_bootstrap_dir'] %}

{% if not use_symlink_for_bootstrap_dir %}

# Copy of bootstrap directory.
bootstrap_directory_copy:
    file.recurse:
        - name: '{{ vagrant_dir }}/bootstrap.dir'
        - source: 'salt://common/bootstrap/bootstrap.dir'
        - makedirs: True
        - user: '{{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}'
        - file_mode: 644
        - dir_mode: 755
        - include_empty: True
        - recurse:
            - user
            - group
            - mode

{% else %}

{% set repo_name = 'common-salt-states' %}
{% set repo_type = pillar['system_features']['deploy_environment_sources']['source_repo_types'][repo_name] %}

{% if grains['id'] not in [pillar['system_features']['deploy_environment_sources']['source_repositories'][repo_name][repo_type]['source_system_host']] %}
# Minion id should match the host where sources are being changed.
{{ THIS_LINE_MAKES_STATE_FAIL }}
{% endif %}

{% set repo_dir = user_home_dir + '/' + pillar['system_features']['deploy_environment_sources']['source_repositories'][repo_name][repo_type]['origin_uri_ssh_path'] %}

# Symlink to bootstrap directory.
bootstrap_directory_symlink:
    file.symlink:
        - name: '{{ vagrant_dir }}/bootstrap.dir'
        - target: '{{ repo_dir }}/states/common/bootstrap/bootstrap.dir'
        - makedirs: True
        - user: '{{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}'

{% endif %}

{% set project_name = salt['config.get']('this_system_keys:project') %}

# Provide generated target configuration files.
{% for selected_host_name in pillar['system_hosts'].keys() %} # selected_host_name

{% set selected_host = pillar['system_hosts'][selected_host_name] %}

target_env_conf_file_{{ project_name }}_{{ selected_host_name }}:
    file.managed:
        - name: '{{ vagrant_dir }}/bootstrap.dir/conf/{{ project_name }}/{{ selected_host_name }}.py'
        - source: 'salt://common/bootstrap/bootstrap.conf.sls'
        - makedirs: True
        - template: jinja
        - mode: 644
        - user: '{{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}'


{% endfor %} # selected_host_name

{% endif %}
# >>>
###############################################################################

