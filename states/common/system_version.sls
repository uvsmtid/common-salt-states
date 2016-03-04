# Deploy file specifying current system version.

{% if grains['kernel'] == 'Linux' %}
{% set config_temp_dir = pillar['posix_config_temp_dir'] %}
{% endif %}
{% if grains['kernel'] == 'Windows' %}
{% set config_temp_dir = pillar['windows_config_temp_dir'] %}
{% endif %}

{% if grains['kernel'] == 'Linux' %}
'{{ config_temp_dir }}/system_version':
{% endif %}
{% if grains['kernel'] == 'Windows' %}
'{{ config_temp_dir }}\system_version':
{% endif %}
    file.managed:
        - makedirs: True

        {% set project_version_name_key = pillar['project_name'] +'_version_name' %}
        {% set project_version_number_key = pillar['project_name'] + '_version_number' %}
        {% if 'is_release' in pillar['dynamic_build_descriptor'] %}
        {% set is_release_value = pillar['dynamic_build_descriptor']['is_release'] %}
        {% else %}
        {% set is_release_value = 'UNKNOWN' %}
        {% endif %}
        - contents: |
            project_name: {{ pillar['project_name'] }}
            version: {{ pillar['dynamic_build_descriptor'][project_version_name_key] }}-{{ pillar['dynamic_build_descriptor'][project_version_number_key] }}
            is_release: {{ is_release_value }}

###############################################################################
# EOF
###############################################################################

