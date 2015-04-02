# Maven installation.

###############################################################################
{% if grains['os_platform_type'].startswith('rhel7') %}

install_openstack_client_packages:
    pkg.installed:
        - pkgs:
            - python-glanceclient
            - python-novaclient

openstack_client_environment_variables_script:
    file.managed:
        - name: '/etc/profile.d/common.openstack.client.variables.sh'
        - source: 'salt://common/openstack/client/common.openstack.client.variables.sh'
        - mode: 555
        - template: jinja

{% endif %}
###############################################################################

