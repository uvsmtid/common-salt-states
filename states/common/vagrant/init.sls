# Virtualization automation using Vagrant project.

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


