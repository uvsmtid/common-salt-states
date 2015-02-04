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
{% if grains['id'] in pillar['system_host_roles']['hypervisor_role']['assigned_hosts'] %}

install_vagrant_packages:
    pkg.installed:
        - pkgs:
            - vagrant

{% set vagrant_dir = pillar['system_hosts'][grains['id']]['primary_user']['posix_user_home_dir'] + '/' + pillar['system_features']['vagrant_configuration']['vagrant_file_dir'] %}

deploy_vagrant_file:
    file.managed:
        - name: '{{ vagrant_dir }}/Vagrantfile'
        - source: 'salt://common/vagrant/Vagrantfile.sls'
        - makedirs: True
        - template: jinja
        - mode: 644
        - user: '{{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}'

# Docker requires special configuration.
{% for selected_host_name in pillar['system_hosts'].keys() %}

{% set selected_host = pillar['system_hosts'][selected_host_name] %}

{% if selected_host['instantiated_by'] %}

{% set instantiated_by = selected_host['instantiated_by'] %}
{% set instance_configuration = selected_host[instantiated_by] %}

{% if instance_configuration['vagrant_provider'] == 'docker' %}

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


