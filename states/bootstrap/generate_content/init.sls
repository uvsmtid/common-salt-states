#

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel7') or grains['os_platform_type'].startswith('fc') %}

include:
    - bootstrap

{% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
{% set user_home_dir = account_conf['posix_user_home_dir'] %}
{% set bootstrap_files_dir = pillar['system_features']['static_bootstrap_configuration']['bootstrap_files_dir'] %}
{% set bootstrap_dir = user_home_dir + '/' + bootstrap_files_dir %}

# Note that `load_bootstrap_target_envs` is only available when Salt
# configuration (for either master or minion) contains necessary configuration.
# In addition to that, the limit on which target environments are generated
# is also placed by `enable_bootstrap_target_envs` key in pillar.
# See:
#   * docs/configs/common/this_system_keys/load_bootstrap_target_envs/readme.md
#   * docs/pillars/{# project_name #}/system_features/source_bootstrap_configuration/enable_bootstrap_target_envs/readme.md
{% set load_bootstrap_target_envs = salt['config.get']('this_system_keys:load_bootstrap_target_envs') %}
{% set project_name = salt['config.get']('this_system_keys:project_name') %}

# Download file for pretty conversion.
pretty_yaml2json_script:
    file.managed:
        - name: '{{ bootstrap_dir }}/pretty_yaml2json.py'
        - source: 'salt://bootstrap/generate_content/pretty_yaml2json.py'
        - makedirs: True
        - user: '{{ account_conf['username'] }}'
        - group: '{{ account_conf['primary_group'] }}'
        - mode: 755

{% for profile_name in load_bootstrap_target_envs.keys() %} # profile_name

{% if profile_name in pillar['system_features']['source_bootstrap_configuration']['enable_bootstrap_target_envs'].keys() %} # enabled profile_name

# Define root for pillar data.
# Note that currently selected profile_name for currently selected project
# is not loaded under `bootstrap_target_envs` pillar key.
# See:
#   * docs/configs/bootstrap/this_system_keys/load_bootstrap_target_envs/readme.md
{% set target_env_pillar = pillar['bootstrap_target_envs'][project_name + '.' + profile_name] %}

{% set target_contents_dir = bootstrap_dir + '/targets/' + project_name + '/' + profile_name %}

# Provide generated target configuration files.
# NOTE: The configuration is repeated for
#       each project_name, each profile_name, each host id even though differences
#       sometimes matter only for specific project_name.
{% for selected_host_name in target_env_pillar['system_hosts'].keys() %} # selected_host_name

{% set selected_host = target_env_pillar['system_hosts'][selected_host_name] %}

{% set requisite_config_file_id = 'target_env_conf_file_' + project_name + '_' + profile_name + '_' + selected_host_name %}
{% set requisite_config_file_path = target_contents_dir + '/conf/' + project_name + '/' + profile_name + '/' + selected_host_name + '.py' %}

cleanup_{{ target_contents_dir }}_{{ selected_host_name }}:
    file.absent:
        - name: '{{ target_contents_dir }}/{{ selected_host_name }}'

{{ requisite_config_file_id }}:
    file.managed:
        - name: '{{ requisite_config_file_path }}'
        - source: 'salt://bootstrap/generate_content/bootstrap.conf.sls'
        - context:
            os_platform: '{{ selected_host['os_platform'] }}'
            project_name: '{{ project_name }}'
            profile_name: '{{ profile_name }}'
            system_host_id: '{{ selected_host_name }}'
        - makedirs: True
        - template: jinja
        - mode: 644
        {% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
        - user: '{{ account_conf['username'] }}'
        - group: '{{ account_conf['primary_group'] }}'
        - require:
            - sls: bootstrap

{% for deploy_step in target_env_pillar['system_features']['static_bootstrap_configuration']['deploy_steps_params'].keys() %} # deploy_step

# Load the function:
{% set deploy_step_source = 'bootstrap/generate_content/deploy_steps/' + deploy_step + '/init.sls' %}
{% from deploy_step_source import configure_deploy_step_function with context %}

# Call the function:
{{
    configure_deploy_step_function(
        pillar,
        target_env_pillar,
        selected_host_name,
        deploy_step,
        target_env_pillar['system_features']['static_bootstrap_configuration']['deploy_steps_params'][deploy_step],
        project_name,
        profile_name,
        requisite_config_file_id,
        requisite_config_file_path,
        target_contents_dir,
        bootstrap_dir,
    )
}}

{% endfor %} # deploy_step

# Copy scripts content per each project_name and profile_name.
{{ requisite_config_file_id }}_modules_copy_script_to_packages:
    cmd.run:
        - name: 'rsync -avp {{ bootstrap_dir }}/modules/ {{ target_contents_dir }}/modules/'
{{ requisite_config_file_id }}_bootstrap.py_copy_script_to_packages:
    cmd.run:
        - name: 'rsync -avp {{ bootstrap_dir }}/bootstrap.py {{ target_contents_dir }}/bootstrap.py'

# Check whether generation of packages is required (time consuming).
{% if pillar['system_features']['source_bootstrap_configuration']['generate_packages'] %} # generate_packages

# Create destination package directory.
{{ requisite_config_file_id }}_create_package_directory:
    file.directory:
        - name: '{{ bootstrap_dir }}/packages/{{ project_name }}/{{ profile_name }}'
        - makedirs: True
        {% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
        - user: '{{ account_conf['username'] }}'
        - group: '{{ account_conf['primary_group'] }}'

# Pack target directories depending on the package type.
{{ requisite_config_file_id }}_create_package_archive:
    cmd.run:
{% set package_type = target_env_pillar['system_features']['static_bootstrap_configuration']['os_platform_package_types'][target_env_pillar['system_hosts'][selected_host_name]['os_platform']] %}
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

{% endif %}
# >>>
###############################################################################

