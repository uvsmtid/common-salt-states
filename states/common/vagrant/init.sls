# Virtualization automation using Vagrant project.

include:

{% for selected_host_name in pillar['system_hosts'].keys() %}

{% set selected_host = pillar['system_hosts'][selected_host_name] %}

{% if selected_host['instantiated_by'] %}

{% set instantiated_by = selected_host['instantiated_by'] %}
{% set instance_configuration = selected_host[instantiated_by] %}
{% set selected_provider = instance_configuration['vagrant_provider'] %}
{% set selected_provider_deployment_state = pillar['system_features']['vagrant_configuration']['vagrant_providers_configs'][selected_provider]['deployment_state'] %}

    - {{ selected_provider_deployment_state }}

{% endif %} # instantiated_by
{% endfor %}

    - common.dummy

###############################################################################
# <<<
{% if grains['os'] in [ 'Fedora' ] %}

# To avoid unnecessary installation,
# require this host to be assigned to `hypervisor_role`.
{% if grains['id'] in pillar['system_host_roles']['hypervisor_role']['assigned_hosts'] %} # hypervisor_role

install_vagrant_packages:
    pkg.installed:
        - pkgs:
            - vagrant
        - aggregate: True

{% set user_home_dir = pillar['system_hosts'][grains['id']]['primary_user']['posix_user_home_dir'] %}
{% set bootstrap_files_dir = pillar['system_features']['bootstrap_configuration']['bootstrap_files_dir'] %}
{% set vagrant_files_dir = pillar['system_features']['vagrant_configuration']['vagrant_files_dir'] %}
{% set vagrant_dir = user_home_dir + '/' + vagrant_files_dir %}
# NOTE: `bootstrap_dir` is under `vagrant_dir` due to some issues of rsync-ing
#        content via symlinks.
#        Normally, `bootstrap_dir` and `vagrant_dir` are in user's home.
{% set bootstrap_dir = user_home_dir + '/' + vagrant_files_dir + '/' + bootstrap_files_dir %}

# Generate Vagrant file.
deploy_vagrant_file:
    file.managed:
        - name: '{{ vagrant_dir }}/Vagrantfile'
        - source: 'salt://common/vagrant/Vagrantfile.sls'
        - makedirs: True
        - template: jinja
        - mode: 644
        - user: '{{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}'

# Set symlink to bootstrap directory.
# TODO: Normally, `bootstrap_dir` and `vagrant_dir` are in user's home
#       and `vagrant_dir` has a symlink to access `bootstrap_dir`.
#       But for now `bootstrap_dir` was placed inside `vagrant_dir`
#       because somehow Vagrant was unable to rsync `bootstrap_dir`
#       via symlink properly regardless of what rsync options were provided.
{% if False %}
bootstrap_symlink_from_vagrant_dir:
    file.symlink:
        - name: '{{ vagrant_dir }}/{{ bootstrap_files_dir }}'
        - target: '{{ bootstrap_dir }}'
        - require:
            - file: deploy_vagrant_file
{% endif %}

# Docker requires special configuration.
{% for selected_host_name in pillar['system_hosts'].keys() %} # selected_host_name

{% set selected_host = pillar['system_hosts'][selected_host_name] %}

{% if selected_host['instantiated_by'] %} # instantiated_by

{% set instantiated_by = selected_host['instantiated_by'] %}
{% set instance_configuration = selected_host[instantiated_by] %}

{% if instance_configuration['vagrant_provider'] == 'docker' %} # vagrant_provider

'deploy_docker_file_for_{{ selected_host_name }}':
    file.managed:
        - name: '{{ vagrant_dir }}/{{ selected_host_name }}/Dockerfile'
        - source: 'salt://common/docker/Dockerfile.sls'
        - makedirs: True
        - template: jinja
        - context:
            selected_host_name: '{{ selected_host_name }}'
        - mode: 644
        - user: '{{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}'

{% endif %} # vagrant_provider

{% endif %} # instantiated_by

{% endfor %} # selected_host_name

# NOTE: You will still have to use `--insecure` option to download box:
#         vagrant box add uvsmtid/centos-7.0-minimal --insecure
vagrant_environment_variables_script:
    file.managed:
        - name: '/etc/profile.d/common.vagrant.variables.sh'
        - source: 'salt://common/vagrant/common.vagrant.variables.sh'
        - mode: 555
        - template: jinja

{% endif %} # hypervisor_role

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

# TODO

{% endif %}
# >>>
###############################################################################


