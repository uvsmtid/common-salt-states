#

###############################################################################
#

{% if grains['os_platform_type'].startswith('rhel7') or grains['os_platform_type'].startswith('fc') %}

include:
    - bootstrap

{% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
{% set user_home_dir = account_conf['posix_user_home_dir'] %}
{% set bootstrap_files_dir = pillar['system_features']['static_bootstrap_configuration']['bootstrap_files_dir'] %}
{% set bootstrap_dir = user_home_dir + '/' + bootstrap_files_dir %}

{% set project_name = properties['properties']['project_name'] %}

# Download file for pretty conversion.
pretty_yaml2json_script:
    file.managed:
        - name: '{{ bootstrap_dir }}/pretty_yaml2json.py'
        - source: 'salt://bootstrap/generate_content/pretty_yaml2json.py'
        - makedirs: True
        - user: '{{ account_conf['username'] }}'
        - group: '{{ account_conf['primary_group'] }}'
        - mode: 755

{% set target_env_pillar = pillar['bootstrap_target_profile'] %}
{% set profile_name = target_env_pillar['properties']['profile_name'] %}

{% if project_name != target_env_pillar['properties']['project_name'] %}
{{ FAIL_HERE_project_name_does_not_match }}
{% endif %}

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

req_file_{{ requisite_config_file_id }}:
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
{% from deploy_step_source import configure_selected_host_step_function with context %}

# Call the function:
{{
    configure_selected_host_step_function(
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

{% endfor %} # selected_host_name

{% for deploy_step in target_env_pillar['system_features']['static_bootstrap_configuration']['deploy_steps_params'].keys() %} # deploy_step

# Load the function:
{% set deploy_step_source = 'bootstrap/generate_content/deploy_steps/' + deploy_step + '/init.sls' %}
{% from deploy_step_source import prepare_resources_step_function with context %}

# Call the function:
{{
    prepare_resources_step_function(
        pillar,
        target_env_pillar,
        deploy_step,
        target_env_pillar['system_features']['static_bootstrap_configuration']['deploy_steps_params'][deploy_step],
        project_name,
        profile_name,
        target_contents_dir,
        bootstrap_dir,
    )
}}

{% endfor %} # deploy_step

# Copy scripts content per each project_name and profile_name.
{% for item_path in [
        'modules/',
        'bootstrap.py',
        'bootstrap.ps1',
        'run_bootstrap.sh',
        'run_bootstrap.cmd',
    ]
%}
req_file_{{ target_contents_dir }}_{{ item_path }}__copy_to_packages:
    cmd.run:
        - name: 'rsync -avp {{ bootstrap_dir }}/{{ item_path }} {{ target_contents_dir }}/{{ item_path }}'
{% endfor %}

# Check whether generation of packages is required (time consuming).
{% if pillar['system_features']['source_bootstrap_configuration']['generate_packages'] %} # generate_packages

# Create destination package directory.
req_file_{{ target_contents_dir }}_create_package_directory:
    file.directory:
        - name: '{{ bootstrap_dir }}/packages/{{ project_name }}/{{ profile_name }}'
        - makedirs: True
        {% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
        - user: '{{ account_conf['username'] }}'
        - group: '{{ account_conf['primary_group'] }}'

# Optimization: remove bootstrap packages and generate only if absent.
{% for selected_host_name in target_env_pillar['system_hosts'].keys() %} # selected_host_name
{% set package_type = target_env_pillar['system_features']['static_bootstrap_configuration']['os_platform_package_types'][target_env_pillar['system_hosts'][selected_host_name]['os_platform']] %}
{% set result_file = bootstrap_dir + '/packages/' + project_name + '/' + profile_name + '/salt-auto-install.' + package_type %}
bootstrap_package_{{ target_contents_dir }}_remove_package_archive_{{ selected_host_name }}_{{ package_type }}:
    cmd.run:
{% if not package_type %} # package_type
        - name: 'echo "WARNING: package type is not specified - no package was removed"'
{% elif package_type == 'tar.gz' %} # package_type
        - name: 'rm -rf {{ result_file }}'
        - cwd: '{{ bootstrap_dir }}/targets/{{ project_name }}/{{ profile_name }}'
{% elif package_type == 'zip' %} # package_type
        - name: 'rm -rf {{ result_file }}'
        - cwd: '{{ bootstrap_dir }}/targets/{{ project_name }}/{{ profile_name }}'
{% else %} # package_typer
        # FAIL if package type is not recognized.
        - name: '{{ UNSUPPORTED_PACKAGE_TYPE }}'
{% endif %} # package_type

{% endfor %} # selected_host_name

# This step generates bootstrap packages per `selected_host_name`,
# but it only happens when specific `package_type` hasn't been generated yet.
# Before generating new ones, all `package_type`s are deleted above.
{% for selected_host_name in target_env_pillar['system_hosts'].keys() %} # selected_host_name
# Pack target directories depending on the package type.
{% set package_type = target_env_pillar['system_features']['static_bootstrap_configuration']['os_platform_package_types'][target_env_pillar['system_hosts'][selected_host_name]['os_platform']] %}
{% set result_file = bootstrap_dir + '/packages/' + project_name + '/' + profile_name + '/salt-auto-install.' + package_type %}
bootstrap_package_{{ target_contents_dir }}_create_package_archive_{{ selected_host_name }}_{{ package_type }}:
    cmd.run:
{% if not package_type %} # package_type
        - name: 'echo "WARNING: package type is not specified - no package was generated"'
{% elif package_type == 'tar.gz' %} # package_type
        # Pack targets directories using `tar`.
        - name: 'tar -cvzf {{ result_file }} .'
        - cwd: '{{ bootstrap_dir }}/targets/{{ project_name }}/{{ profile_name }}'
        - unless: 'ls {{ result_file }}'
{% elif package_type == 'zip' %} # package_type
        # Pack targets directories using `zip`.
        - name: 'zip -r {{ result_file }} .'
        - cwd: '{{ bootstrap_dir }}/targets/{{ project_name }}/{{ profile_name }}'
        - unless: 'ls {{ result_file }}'
{% else %} # package_typer
        # FAIL if package type is not recognized.
        - name: '{{ UNSUPPORTED_PACKAGE_TYPE }}'
{% endif %} # package_type

{% endfor %} # selected_host_name

{% endif %} # generate_packages

{% endif %}

###############################################################################
# EOF
###############################################################################

