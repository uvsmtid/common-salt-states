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
{% if grains['os'] in [ 'RedHat', 'CentOS' ] %}

# TODO: Implement configuration on RHEL5.

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Fedora' ] %}

{% set content_parent_dir = pillar['system_features']['validate_depository_content']['depository_content_parent_dir'] %}
{% set content_item = pillar['system_resources']['custom_root_CA_certificate'] %}
{% set item_parent_dir_path = content_item['item_parent_dir_path'] %}
{% set item_base_name = content_item['item_base_name'] %}
{% set item_content_hash = content_item['item_content_hash'] %}

custom_root_ca:
    file.managed:
        - name: '/usr/share/pki/ca-trust-source/anchors/{{ item_base_name }}'
        - source: http://depository-role/{{ item_parent_dir_path }}/{{ item_base_name }}
        - source_hash: {{ item_content_hash }}
        - template: null
        - user: root
        - group: root
        - mode: 644

update_ca_trust_command:
    cmd.run:
        - name: 'update-ca-trust'
        - require:
            - file: custom_root_ca

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

# TODO: Implement configuration on Windows.

{% endif %}
# >>>
###############################################################################


