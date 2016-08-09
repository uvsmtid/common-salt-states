# This state deploys a generated xml project file for Class Visualizer.
# See:
#   http://www.class-visualizer.net/
#
# The generated xml project file only contains paths to `*.jar` files
# which are internal to our Maven sources.

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

{% set primary_user = pillar['system_hosts'][grains['id']]['primary_user'] %}
{% set account_conf = pillar['system_accounts'][ primary_user ] %}

class_visualizer_project_file:
    file.managed:
        - name: '{{ account_conf['posix_user_home_dir'] }}/{{ pillar['properties']['project_name'] }}.class_visualizer.xml'
        - source: 'salt://common/class_visualizer/project.class_visualizer.xml'
        - template: jinja
        - user: {{ account_conf['username'] }}
        - group: {{ account_conf['primary_group'] }}
        - mode: 644

# The following loop to create empty `target/classes` directories is
# required because not every Maven component compiles Java code into classes.

{% from 'common/libs/host_config_queries.sls' import get_system_host_primary_user_posix_home with context %}

{% for artifact_id in pillar['system_maven_artifacts']['artifact_descriptors'].keys() %}

{% set artifact_conf = pillar['system_maven_artifacts']['artifact_descriptors'][artifact_id] %}

{% if artifact_conf['used'] %}

{% if artifact_conf['source_type'] in [
        'available-closed'
        ,
        'modified-open'
    ]
%}

{% set repo_name = artifact_conf['repository_id'] %}

{% set repo_config = pillar['system_features']['deploy_environment_sources']['source_repositories'][repo_name]['git'] %}

{% set repo_path = get_system_host_primary_user_posix_home(repo_config['source_system_host']) + '/' + repo_config['origin_uri_ssh_path'] %}

{% set pom_relative_dir_path = artifact_conf['pom_relative_dir_path'] %}

'create_classes_dir_{{ repo_path }}/{{ pom_relative_dir_path }}/target/classes':
    file.directory:
        - name: '{{ repo_path }}/{{ pom_relative_dir_path }}/target/classes'
        - makedirs: True
        # Do not create sub-directory if parent directory does not exists.
        - onlyif: 'ls {{ repo_path }}/{{ pom_relative_dir_path }}'
        - user: {{ account_conf['username'] }}
        - group: {{ account_conf['primary_group'] }}
        - mode: 755

{% endif %}

{% endif %}

{% endfor %}

{% endif %}
# >>>
###############################################################################

