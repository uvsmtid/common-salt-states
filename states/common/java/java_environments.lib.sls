# Some macros to automate managing Java environments.

###############################################################################

{% macro install_java_environment(
        java_environment_id
    )
%}

{% from 'common/libs/utils.lib.sls' import get_salt_content_temp_dir with context %}

{% set je_config = pillar['system_features']['java_environments_configuration']['java_environments'][java_environment_id] %}

{% set resources_macro_lib = 'common/resource_symlinks/resources_macro_lib.sls' %}
{% from resources_macro_lib import get_registered_content_item_URI with context %}
{% from resources_macro_lib import get_registered_content_item_hash with context %}

{% if not je_config['installation_type'] %}
# Nothing to do.
{% elif je_config['installation_type'] == 'package_resources' %} # installation_type
#
{% for package_resource_name in je_config['package_resources'].keys() %} # package_resource_name

{% set package_resource_conf = je_config['package_resources'][package_resource_name] %}
{% set hosts_os_platform = pillar['system_hosts'][grains['id']]['os_platform'] %}
{% set rpm_options = package_resource_conf['rpm_options'] %}
{% set rpm_version = je_config['os_platform_configs'][hosts_os_platform]['rpm_version'] %}

{% if not package_resource_conf['resource_type'] %} # resource_type
# Nothing to do.
{% elif package_resource_conf['resource_type'] == 'rpm' %} # resource_type

{% set content_item_conf = pillar['system_resources'][package_resource_conf['resource_id']] %}

download_rpm_package_{{ java_environment_id }}_{{ package_resource_name }}:
    file.managed:
        - name: '{{ get_salt_content_temp_dir() }}/{{ content_item_conf['item_base_name'] }}'
        - source: {{ get_registered_content_item_URI(package_resource_conf['resource_id']) }}
        - source_hash: {{ get_registered_content_item_hash(package_resource_conf['resource_id']) }}
        - makedirs: True

run_rpm_command_{{ java_environment_id }}_{{ package_resource_name }}:
    cmd.run:
        - name: 'rpm -ihv {{ rpm_options }} "{{ get_salt_content_temp_dir() }}/{{ content_item_conf['item_base_name'] }}"'
        # NOTE: Some packages are internally named differently based on the target platform.
        - unless: 'rpm -qi {{ rpm_version }}'
        - require:
            - file: download_rpm_package_{{ java_environment_id }}_{{ package_resource_name }}

{% else %} # resource_type
{{ UNSUPPORTED_resource_type }}
{% endif %} # resource_type

{% endfor %} # package_resource_name

{% elif je_config['installation_type'] == 'yum_repositories' %} # installation_type

install_rpm_packages_{{ java_environment_id }}:
    pkg.installed:
        - pkgs: {{ je_config['rpm_packages'] }}
        - aggregate: True

{% endif %} # installation_type

{% endmacro %}

###############################################################################

{%- macro get_java_environment_JAVA_HOME(
        java_environment_id
    )
-%}
{%- set hosts_os_platform = pillar['system_hosts'][grains['id']]['os_platform'] -%}
{{- pillar['system_features']['java_environments_configuration']['java_environments'][java_environment_id]['os_platform_configs'][hosts_os_platform]['JAVA_HOME'] -}}
{%- endmacro -%}

