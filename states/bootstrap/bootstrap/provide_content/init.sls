#

###############################################################################
# <<<
{% if grains['os'] in [ 'Fedora' ] %}

include:
    - bootstrap.bootstrap

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
#   * docs/pillars/{# project_name #}/system_features/bootstrap_configuration/enable_bootstrap_target_envs/readme.md
{% set load_bootstrap_target_envs = salt['config.get']('this_system_keys:load_bootstrap_target_envs') %}
{% set current_project_name = salt['config.get']('this_system_keys:project') %}
{% set current_profile_name = salt['config.get']('this_system_keys:profile') %}

# Download file for pretty conversion.
pretty_yaml2json_script:
    file.managed:
        - name: '{{ bootstrap_dir }}/pretty_yaml2json.py'
        - source: 'salt://bootstrap/bootstrap/provide_content/pretty_yaml2json.py'
        - makedirs: True
        - user: '{{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}'
        - mode: 755

{% for project_name in load_bootstrap_target_envs.keys() %} # project_name

{% if project_name in pillar['system_features']['bootstrap_configuration']['enable_bootstrap_target_envs'].keys() %} # enabled project_name

{% for profile_name in load_bootstrap_target_envs[project_name].keys() %} # profile_name

{% if profile_name in pillar['system_features']['bootstrap_configuration']['enable_bootstrap_target_envs'][project_name].keys() %} # enabled profile_name

# Define root for pillar data.
# Note that currently selected profile for currently selected project
# is not loaded under `bootstrap_target_envs` pillar key.
# See:
#   * docs/configs/bootstrap/this_system_keys/load_bootstrap_target_envs/readme.md
{% if project_name == current_project_name and profile_name == current_profile_name %}
{% set target_env_pillar = pillar %}
{% else %}
{% set target_env_pillar = pillar['bootstrap_target_envs'][project_name + '.' + profile_name] %}
{% endif %}

{% set target_contents_dir = bootstrap_dir + '/targets/' + project_name + '/' + profile_name %}

# Provide generated target configuration files.
# NOTE: The configuration is repeated for
#       each project, each profile, each host id even though differences
#       sometimes matter only for specific project.
{% for selected_host_name in target_env_pillar['system_hosts'].keys() %} # selected_host_name

{% set selected_host = target_env_pillar['system_hosts'][selected_host_name] %}

{% set requisite_config_file_id = 'target_env_conf_file_' + project_name + '_' + profile_name + '_' + selected_host_name %}
{% set requisite_config_file_path = target_contents_dir + '/conf/' + project_name + '/' + profile_name + '/' + selected_host_name + '.py' %}

{{ requisite_config_file_id }}:
    file.managed:
        - name: '{{ requisite_config_file_path }}'
        - source: 'salt://bootstrap/bootstrap/provide_content/bootstrap.conf.sls'
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
            - sls: bootstrap.bootstrap

{% for deploy_step in target_env_pillar['system_features']['bootstrap_configuration']['deploy_steps_params'].keys() %} # deploy_step

# Load the function:
{% set deploy_step_source = 'bootstrap/bootstrap/provide_content/deploy_steps/' + deploy_step + '/init.sls' %}
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
        target_contents_dir,
        bootstrap_dir,
    )
}}

{% endfor %} # deploy_step

# Copy scripts content per each project and profile.
{{ requisite_config_file_id }}_modules_copy_script_to_packages:
    cmd.run:
        - name: 'rsync -avp {{ bootstrap_dir }}/modules/ {{ target_contents_dir }}/modules/'
{{ requisite_config_file_id }}_bootstrap.py_copy_script_to_packages:
    cmd.run:
        - name: 'rsync -avp {{ bootstrap_dir }}/bootstrap.py {{ target_contents_dir }}/bootstrap.py'

# Check whether generation of packages is required (time consuming).
{% if target_env_pillar['system_features']['bootstrap_configuration']['generate_packages'] %} # generate_packages

# Create destination package directory.
{{ requisite_config_file_id }}_create_package_directory:
    file.directory:
        - name: '{{ bootstrap_dir }}/packages/{{ project_name }}/{{ profile_name }}'
        - makedirs: True
        - user: '{{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}'

# Pack target directories depending on the package type.
{{ requisite_config_file_id }}_create_package_archive:
    cmd.run:
{% set package_type = target_env_pillar['system_features']['bootstrap_configuration']['os_platform_package_types'][target_env_pillar['system_hosts'][selected_host_name]['os_platform']] %}
{% if not package_type %} # package_type
{% elif package_type == 'tar.gz' %} # package_type
        # Pack targets directories.
        - name: 'tar -cvzf {{ bootstrap_dir }}/packages/{{ project_name }}/{{ profile_name }}/salt-auto-install.{{ package_type }} .'
        - cwd: '{{ bootstrap_dir }}/targets/{{ project_name }}/{{ profile_name }}'
{% else %} # package_type
        - name: 'echo "unsupported package type - no package was generated"'
{% endif %} # package_type

{% endif %} # generate_packages

{% endfor %} # selected_host_name

{% endif %} # enabled profile_name

{% endfor %} # profile_name

{% endif %} # enabled project_name

{% endfor %} # project_name

{% endif %}
# >>>
###############################################################################

