# Some macros to automate managing Java environments.

###############################################################################

{% macro install_java_environment(
        java_environment_id
    )
%}

{% if grains['kernel'] == 'Linux' %}
{% set config_temp_dir = pillar['posix_config_temp_dir'] %}
{% endif %}
{% if grains['kernel'] == 'Windows' %}
{% set config_temp_dir = pillar['windows_config_temp_dir'] %}
{% endif %}

{% set je_config = pillar['system_features']['java_environments_configuration']['java_environments'][java_environment_id] %}

{% set resources_macro_lib = 'common/resource_symlinks/resources_macro_lib.sls' %}
{% from resources_macro_lib import get_registered_content_item_URI with context %}
{% from resources_macro_lib import get_registered_content_item_hash with context %}

{% if not je_config['installation_type'] %}
# Nothing to do.
{% elif je_config['installation_type'] == 'rpm_sources' %} # installation_type
#
{% for rpm_source_name in je_config['rpm_sources'].keys() %} # rpm_source_name

{% set rpm_source_conf = je_config['rpm_sources'][rpm_source_name] %}
{% set hosts_os_platform = pillar['system_hosts'][grains['id']]['os_platform'] %}
{% set rpm_options = rpm_source_conf['rpm_options'] %}
{% set rpm_version = je_config['os_platform_configs'][hosts_os_platform]['rpm_version'] %}

{% if not rpm_source_conf['source_type'] %} # source_type
# Nothing to do.
{% elif rpm_source_conf['source_type'] == 'rpm' %} # source_type

{% set content_item_conf = pillar['system_resources'][rpm_source_conf['resource_id']] %}

download_rpm_package_{{ java_environment_id }}_{{ rpm_source_name }}:
    file.managed:
        - name: '{{ config_temp_dir }}/{{ content_item_conf['item_base_name'] }}'
        - source: {{ get_registered_content_item_URI(rpm_source_conf['resource_id']) }}
        - source_hash: {{ get_registered_content_item_hash(rpm_source_conf['resource_id']) }}
        - makedirs: True

run_rpm_command_{{ java_environment_id }}_{{ rpm_source_name }}:
    cmd.run:
        - name: 'rpm -ihv {{ rpm_options }} "{{ config_temp_dir }}/{{ content_item_conf['item_base_name'] }}"'
        # NOTE: Some packages are internally named differently based on the target platform.
        - unless: 'rpm -qi {{ rpm_version }}'
        - require:
            - file: download_rpm_package_{{ java_environment_id }}_{{ rpm_source_name }}

{% else %} # source_type
{{ UNSUPPORTED_source_type }}
{% endif %} # source_type

{% endfor %} # rpm_source_name

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

