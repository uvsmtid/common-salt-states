#

###############################################################################
# <<<
{% if grains['os'] in [ 'Fedora' ] %}

include:
    - common.bootstrap

{% set user_home_dir = pillar['system_hosts'][grains['id']]['primary_user']['posix_user_home_dir'] %}
{% set bootstrap_files_dir = pillar['system_features']['bootstrap_configuration']['bootstrap_files_dir'] %}
{% set vagrant_files_dir = pillar['system_features']['vagrant_configuration']['vagrant_files_dir'] %}
{% set vagrant_dir = user_home_dir + '/' + vagrant_files_dir %}
# NOTE: `bootstrap_dir` is under `vagrant_dir` due to some issues of rsync-ing
#        content via symlinks.
#        Normally, `bootstrap_dir` and `vagrant_dir` are in user's home.
{% set bootstrap_dir = user_home_dir + '/' + vagrant_files_dir + '/' + bootstrap_files_dir %}

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
# NOTE: The configuration is repeated for
#       each project, each profile, each host id even though differences
#       sometimes matter only for specific project.
{% for selected_host_name in target_env_pillar['system_hosts'].keys() %} # selected_host_name

{% set selected_host = target_env_pillar['system_hosts'][selected_host_name] %}

{% set requisite_config_file_id = 'target_env_conf_file_' + project_name + '_' + profile_name + '_' + selected_host_name %}
{% set requisite_config_file_path = bootstrap_dir + '/conf/' + project_name + '/' + profile_name + '/' + selected_host_name + '.py' %}

{{ requisite_config_file_id }}:
    file.managed:
        - name: '{{ requisite_config_file_path }}'
        - source: 'salt://common/bootstrap/provide_content/bootstrap.conf.sls'
        - context:
            os_platform: '{{ selected_host['os_platform'] }}'
            project_name: '{{ project_name }}'
            profile_name: '{{ profile_name }}'
            system_host_id: '{{ selected_host_name }}'
        - makedirs: True
        - template: jinja
        - mode: 644
        - user: '{{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}'
        - require:
            - sls: common.bootstrap

{% for deploy_step in target_env_pillar['system_features']['bootstrap_configuration']['deploy_steps_params'].keys() %} # deploy_step

# Load the function:
{% set deploy_step_source = 'common/bootstrap/provide_content/deploy_steps/' + deploy_step + '/init.sls' %}
{% from deploy_step_source import configure_deploy_step_function with context %}

# Call the function:
{{
    configure_deploy_step_function(
        pillar,
        target_env_pillar,
        selected_host_name,
        deploy_step,
        target_env_pillar['system_features']['bootstrap_configuration']['deploy_steps_params'][deploy_step],
        project_name,
        profile_name,
        requisite_config_file_id,
        requisite_config_file_path,
        bootstrap_dir,
    )
}}

{% endfor %} # deploy_step

{% endfor %} # selected_host_name

# Load function to get host id from role name.
{% from 'common/libs/host_config_queries.sls' import get_host_id_by_role_from_pillar with context %}
# Get _any_ known host id:
{% set system_host_id = get_host_id_by_role_from_pillar('controller_role', target_env_pillar) %}

# Generate package for each profile.
# TODO: At the moment it is not clear why `build` command is even needed
#       to be implemented within bootstrap script. All content is already
#       genarated through Salt and `build` step seems redundant if Salt
#       can provide everything.
#       The only thing which `build` command in bootstrap does is some
#       speed optimization (by avoiding pushing more states instantiated
#       in this template to be executed by Salt).
# TODO: At the moment use case does not affect `build` command of bootstrap
#       script anyhow. Think to
# TODO: At the moment config file specified for `build` command is specific
#       to host. There is nothing host-specific taken from this configuration.
#       It's just a way to specify project and profile (part of the config
#       file).
{{ project_name }}_{{ profile_name }}_generate_bootstrap_package:
    cmd.run:
        - name: 'python bootstrap.py build offline-minion-installer conf/{{ project_name }}/{{ profile_name }}/{{ system_host_id }}.py'
        - cwd: '{{ bootstrap_dir }}'
        - user: '{{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}'

{% endif %} # enabled profile_name

{% endfor %} # profile_name

{% endif %} # enabled project_name

{% endfor %} # project_name

{% endif %}
# >>>
###############################################################################

