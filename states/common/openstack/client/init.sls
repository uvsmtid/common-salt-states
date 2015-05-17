# Maven installation.

{% if grains['kernel'] == 'Linux' %}
{% set config_temp_dir = pillar['posix_config_temp_dir'] %}
{% endif %}
{% if grains['kernel'] == 'Windows' %}
{% set config_temp_dir = pillar['windows_config_temp_dir'] %}
{% endif %}

###############################################################################
{% if grains['os_platform_type'].startswith('rhel7') or grains['os_platform_type'].startswith('fc21') %}

{% set resources_macro_lib = 'common/resource_symlinks/resources_macro_lib.sls' %}
{% from resources_macro_lib import get_registered_content_item_URI with context %}
{% from resources_macro_lib import get_registered_content_item_hash with context %}
{% from resources_macro_lib import get_registered_content_item_base_name with context %}


# DISABLE: The repository is configured by stanard all-in-one YUM config.
#          See: common.yum
#{#

# TODO: NOTE that this yum repository does not work well behind a proxy
#       likely due to the fact that the repo is only accessible over `https`,
#       while URL in the YUM uses `http`.
# Download RPM for `openstack-juno` YUM repository.
{% set local_rpm_file_name = config_temp_dir + '/' + get_registered_content_item_base_name('openstack-rdo-release-juno-1.noarch.rpm') %}
# '{{ config_temp_dir }}/{{ get_registered_content_item_base_name('openstack-rdo-release-juno-1.noarch.rpm') }}':
'{{ local_rpm_file_name }}':
    file.managed:
        - source: {{ get_registered_content_item_URI('openstack-rdo-release-juno-1.noarch.rpm') }}
        - source_hash: {{ get_registered_content_item_hash('openstack-rdo-release-juno-1.noarch.rpm') }}
        - makedirs: True

# Enable `openstack-juno` YUM repository.
enable_openstack-juno_yum_repository:
    cmd.run:
        - name: 'rpm -ihv {{ local_rpm_file_name }}'
        - require:
            - file: '{{ local_rpm_file_name }}'

#}#

install_openstack_client_packages:
    pkg.installed:
        - pkgs:
            - python-glanceclient
            - python-novaclient
            - python-keystoneclient
# DISABLE: See explanation above.
#{#
        - require:
            - cmd: enable_openstack-juno_yum_repository
#}#

openstack_client_environment_variables_script:
    file.managed:
        - name: '/etc/profile.d/common.openstack.client.variables.sh'
        - source: 'salt://common/openstack/client/common.openstack.client.variables.sh'
        - mode: 555
        - template: jinja

{% endif %}
###############################################################################

