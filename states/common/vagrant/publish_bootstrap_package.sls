# Publish bootstrap content

###############################################################################
# <<< Fedora only (Vagrant is not available on RHEL7).
{% if grains['os_platform_type'].startswith('fc') %}

# To avoid unnecessary installation,
# require this host to be assigned to:
# - `virtual_machine_hypervisor_role`
# - `vagrant_box_publisher_role`
{% if grains['id'] in pillar['system_host_roles']['virtual_machine_hypervisor_role']['assigned_hosts'] %} # virtual_machine_hypervisor_role
{% if grains['id'] in pillar['system_host_roles']['vagrant_box_publisher_role']['assigned_hosts'] %} # vagrant_box_publisher_role

# Define properties (they are loaded as values to the root of pillars):
{% set props = pillar %}

{% set project_name = props['project_name'] %}

# NOTE: There is no native way (for clean OSes) for host Linux to
#       upload file to Windows guest using Vagrant (e.g. no implementation
#       for Vagrant "Synced Folders" works natively).
# To make upload possible, `vagrant_box_publisher_role` is used to download file instead
# (from Windows guest to Linux guest).
# This state copies already generated bootstrap package (if available)
# from bootstrap directory to root content dir of `vagrant_box_publisher_role`.
{% set vagrant_box_publisher_role_content_dir = pillar['system_features']['vagrant_box_publisher_configuration']['vagrant_box_publisher_role_content_dir'] %}
{% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
{% set user_home_dir = account_conf['posix_user_home_dir'] %}
{% set bootstrap_files_dir = pillar['system_features']['static_bootstrap_configuration']['bootstrap_files_dir'] %}
{% set bootstrap_dir = user_home_dir + '/' + bootstrap_files_dir %}

# Define root for pillar data.
{% set target_env_pillar = pillar['bootstrap_target_profile'] %}
{% set profile_name = target_env_pillar['profile_name'] %}

{% set target_contents_dir = bootstrap_dir + '/targets/' + project_name + '/' + profile_name %}

# This step copies bootstrap packages per `selected_host_name`,
# but it only happens when specific `package_type` already exists.
{% for selected_host_name in target_env_pillar['system_hosts'].keys() %} # selected_host_name

{% set package_type = target_env_pillar['system_features']['static_bootstrap_configuration']['os_platform_package_types'][target_env_pillar['system_hosts'][selected_host_name]['os_platform']] %}

{% set source_file = bootstrap_dir + '/packages/' + project_name + '/' + profile_name + '/salt-auto-install.' + package_type %}
{% set destination_file_dir = vagrant_box_publisher_role_content_dir + '/packages/' + project_name + '/' + profile_name %}
{% set destination_file = destination_file_dir + '/salt-auto-install.' + package_type %}

bootstrap_package_{{ target_contents_dir }}_make_package_dir_{{ selected_host_name }}_{{ package_type }}:
    file.directory:
        - name: '{{ destination_file_dir }}'
        - makedirs: True

bootstrap_package_{{ target_contents_dir }}_copy_package_archive_{{ selected_host_name }}_{{ package_type }}:
    cmd.run:
        # NOTE: We only copy file if destination is older than source.
        - name: 'cp -up {{ source_file }} {{ destination_file }}'

{% endfor %} # selected_host_name

{% endif %} # virtual_machine_hypervisor_role
{% endif %} # vagrant_box_publisher_role

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

# TODO

{% endif %}
# >>>
###############################################################################


