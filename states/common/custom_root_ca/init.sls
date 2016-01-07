# Install custom root CA certificate.
# This is to make HTTPS-pages automatically accepted by
# Internet browsers on these machines.

{% if grains['kernel'] == 'Linux' %}
{% set config_temp_dir = pillar['posix_config_temp_dir'] %}
{% endif %}
{% if grains['kernel'] == 'Windows' %}
{% set config_temp_dir = pillar['windows_config_temp_dir'] %}
{% endif %}

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel5') %}

# TODO: Implement configuration on RHEL5.

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel7') or grains['os_platform_type'].startswith('fc') %}

{% set content_parent_dir = pillar['system_features']['validate_depository_content']['depository_content_parent_dir'] %}
{% set content_item = pillar['system_resources']['custom_root_CA_certificate'] %}
{% set item_parent_dir_path = content_item['item_parent_dir_path'] %}
{% set item_base_name = content_item['item_base_name'] %}
{% set item_content_hash = content_item['item_content_hash'] %}

# TODO: Rewrite using macros to get resource files.
custom_root_ca:
    file.managed:
        - name: '/usr/share/pki/ca-trust-source/anchors/{{ item_base_name }}'
        - source: http://{{ pillar['system_host_roles']['depository_role']['hostname'] }}/{{ item_parent_dir_path }}/{{ item_base_name }}
        - source_hash: {{ item_content_hash }}
        - template: null
        - user: root
        - group: root
        - mode: 644

ca_trusted_certificates_package:
    pkg.installed:
        - name: ca-certificates
        - aggregate: True

update_ca_trust_command:
    cmd.run:
        - name: 'update-ca-trust'
        - require:
            - file: custom_root_ca
            - pkg: ca_trusted_certificates_package

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

# TODO: Implement configuration on Windows.

{% endif %}
# >>>
###############################################################################


