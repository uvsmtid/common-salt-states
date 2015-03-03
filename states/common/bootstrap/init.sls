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

# Note that `load_bootstrap_target_envs` is only available when Salt
# configuration (for either master or minion) contains necessary configuration.
# In addition to that, the limit on which target environments are generated
# is also placed by `enable_bootstrap_target_envs` key in pillar.
# See:
#   * docs/configs/common/this_system_keys/load_bootstrap_target_envs/readme.md
{% set load_bootstrap_target_envs = salt['config.get']('this_system_keys:load_bootstrap_target_envs') %}
{% set current_project_name = salt['config.get']('this_system_keys:project') %}
{% set current_profile_name = salt['config.get']('this_system_keys:profile') %}

{% for project_name in load_bootstrap_target_envs.keys() %} # project_name

{% if project_name in pillar['system_features']['bootstrap_configuration']['enable_bootstrap_target_envs'].keys() %} # enabled project_name

{% for profile_name in load_bootstrap_target_envs[project_name].keys() %} # profile_name

{% if profile_name in pillar['system_features']['bootstrap_configuration']['enable_bootstrap_target_envs'][project_name].keys() %} # enabled profile_name

# Define root for pillar data.
# Note that currently selected profile for currently selected project
# is not loaded under `bootstrap_target_envs` pillar key.
# See:
#   * docs/configs/common/this_system_keys/load_bootstrap_target_envs/readme.md
{% if project_name == current_project_name and profile_name == current_profile_name %}
{% set target_env_pillar = pillar %}
{% else %}
{% set target_env_pillar = pillar['bootstrap_target_envs'][project_name + '.' + profile_name] %}
{% endif %}

# Provide generated target configuration files.
{% for selected_host_name in target_env_pillar['system_hosts'].keys() %} # selected_host_name

{% set selected_host = target_env_pillar['system_hosts'][selected_host_name] %}

target_env_conf_file_{{ project_name }}_{{ profile_name }}_{{ selected_host_name }}:
    file.managed:
        - name: '{{ vagrant_dir }}/bootstrap.dir/conf/{{ project_name }}/{{ profile_name }}/{{ selected_host_name }}.py'
        - source: 'salt://common/bootstrap/bootstrap.conf.sls'
        - context:
            target_env_pillar: {{ target_env_pillar }}
        - makedirs: True
        - template: jinja
        - mode: 644
        - user: '{{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}'


{% endfor %} # selected_host_name

{% endif %} # enabled profile_name

{% endfor %} # profile_name

{% endif %} # enabled project_name

{% endfor %} # project_name

{% endif %}
# >>>
###############################################################################

