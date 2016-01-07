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

{% set resources_macro_lib = 'common/resource_symlinks/resources_macro_lib.sls' %}
{% from resources_macro_lib import get_registered_content_item_URI with context %}
{% from resources_macro_lib import get_registered_content_item_hash with context %}
{% from resources_macro_lib import get_registered_content_item_base_name with context %}

{% for cert_res_id in pillar['system_features']['custom_root_CA_certificates'] %}

custom_root_ca_{{ cert_res_id }}:
    file.managed:
        - name: '/usr/share/pki/ca-trust-source/anchors/{{ get_registered_content_item_base_name(cert_res_id) }}'
        - source: {{ get_registered_content_item_URI(cert_res_id) }}
        - source_hash: {{ get_registered_content_item_hash(cert_res_id) }}
        - template: null
        - user: root
        - group: root
        - mode: 644

{% endfor %}

ca_trusted_certificates_package:
    pkg.installed:
        - name: ca-certificates
        - aggregate: True

update_ca_trust_command:
    cmd.run:
        - name: 'update-ca-trust'
        - require:
{% for cert_res_id in pillar['system_features']['custom_root_CA_certificates'] %}
            - file: custom_root_ca_{{ cert_res_id }}
{% endfor %}
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


