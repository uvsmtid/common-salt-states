# Deploy file specifying current system version.

{% from 'common/libs/utils.lib.sls' import get_salt_content_temp_dir with context %}

{% if grains['kernel'] == 'Linux' %}
'{{ get_salt_content_temp_dir() }}/system_version':
{% endif %}
{% if grains['kernel'] == 'Windows' %}
'{{ get_salt_content_temp_dir() }}\system_version':
{% endif %}
    file.managed:
        - makedirs: True

        # TODO: Avoid composing key names. Instead use something like
        #       `system_versions` top-level pillar key with
        #       pairs `version_name` and `version_number`
        #       per `project_name` sub-key.
        {% set project_version_name_key = pillar['properties']['project_name'] +'_version_name' %}
        {% set project_version_number_key = pillar['properties']['project_name'] + '_version_number' %}
        {% if 'is_release' in pillar['dynamic_build_descriptor'] %}
        {% set is_release_value = pillar['dynamic_build_descriptor']['is_release'] %}
        {% else %}
        {% set is_release_value = 'UNKNOWN' %}
        {% endif %}
        - contents: |
            project_name: {{ pillar['properties']['project_name'] }}
            {% if project_version_name_key in pillar['dynamic_build_descriptor'] and project_version_number_key in pillar['dynamic_build_descriptor'] %}
            version: {{ pillar['dynamic_build_descriptor'][project_version_name_key] }}-{{ pillar['dynamic_build_descriptor'][project_version_number_key] }}
            {% else %}
            version: UNDEFINED
            {% endif %}
            is_release: {{ is_release_value }}

###############################################################################
# EOF
###############################################################################

