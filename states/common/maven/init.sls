# Maven installation.

###############################################################################
# <<<
# NOTE: RHEL5 does not include `maven` package.
{% if grains['os_platform_type'].startswith('rhel7') or grains['os_platform_type'].startswith('fc') %}

# NOTE: Use specific Maven version from pre-downloaded package.
#       This helps to avoid issues with some plugins, if needed.
{% if False %}

install_maven_package:
    pkg.installed:
        - name: maven
        - aggregate: True

{% else %}

{% set resources_macro_lib = 'common/resource_symlinks/resources_macro_lib.sls' %}
{% from resources_macro_lib import get_registered_content_item_URI with context %}
{% from resources_macro_lib import get_registered_content_item_hash with context %}

{% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
{% set user_home_dir = account_conf['posix_user_home_dir'] %}

{% set resource_id = 'maven_pre_downloaded_rpm' %}

maven_distribution_target_dir:
    file.directory:
        - name: '/opt'
        - makedirs: True

extract_maven_distribution_archive:
    archive.extracted:
        - name: '/opt/maven'
        - source: {{ get_registered_content_item_URI(resource_id) }}
        - source_hash: {{ get_registered_content_item_hash(resource_id) }}
        - archive_format: tar
        - archive_user: '{{ account_conf['username'] }}'
        - require:
            - file: maven_distribution_target_dir

maven_distribution_permissions:
    file.directory:
        - name: '/opt/maven'
        - source: ~

        {% if True %}
        - user: '{{ account_conf['username'] }}'
        - group: '{{ account_conf['primary_group'] }}'
        - recurse:
            - user
            - group
        {% endif %}

        - require:
            - archive: extract_maven_distribution_archive

{% endif %}

{% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
maven_configuration_file:
    file.managed:
        - name: '{{ account_conf['posix_user_home_dir'] }}/.m2/settings.xml'
        # Use pillars-configured location of template so that
        # each project_name can substitute it by its own.
        #- source: 'salt://common/maven/settings.xml.sls'
        - source: '{{ pillar['system_features']['maven_installation_configuration']['settings_xml_template_url'] }}'
        - template: jinja
        - makedirs: True
        - user: '{{ account_conf['username'] }}'
        - group: '{{ account_conf['primary_group'] }}'
        - mode: 644

maven_environment_variables_script:
    file.managed:
        - name: '/etc/profile.d/common.maven.variables.sh'
        - source: 'salt://common/maven/common.maven.variables.sh'
        - mode: 555
        - template: jinja

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

{% endif %}
# >>>
###############################################################################


