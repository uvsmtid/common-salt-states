# Nexus Maven Repository Manager

{% if grains['id'] in pillar['system_host_roles']['maven_repository_manager_role']['assigned_hosts'] %}

{% if grains['kernel'] == 'Linux' %}
{% set config_temp_dir = pillar['posix_config_temp_dir'] %}
{% endif %}
{% if grains['kernel'] == 'Windows' %}
{% set config_temp_dir = pillar['windows_config_temp_dir'] %}
{% endif %}

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS' ] %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Fedora' ] %}

{% if pillar['registered_content_items']['nexus_maven_repository_manager']['enable_installation'] %}

{% set URI_prefix = pillar['registered_content_config']['URI_prefix'] %}

download_nexus_archive:
    file.managed:
        - name: '{{ config_temp_dir }}/nexus/nexus-bundle.tar.gz'
        - source: '{{ URI_prefix }}/{{ pillar['registered_content_items']['nexus_maven_repository_manager']['item_parent_dir_path'] }}/{{ pillar['registered_content_items']['nexus_maven_repository_manager']['item_base_name'] }}'
        - source_hash: {{ pillar['registered_content_items']['nexus_maven_repository_manager']['item_content_hash'] }}
        - makedirs: True
        - user: {{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}
        - group: {{ pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}

ensure_nexus_parent_deployment_dir:
    file.directory:
        - name: '/usr/local'
        - makedirs: True

extract_nexus_archive:
    cmd.run:
        - name: 'tar -xvf "{{ config_temp_dir }}/nexus/nexus-bundle.tar.gz"'
        - cwd: '/usr/local'
        - user: {{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}
        - group: {{ pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}
        - unless: 'ls -ld /usr/local/nexus-{{ pillar['registered_content_items']['nexus_maven_repository_manager']['nexus_bundle_version_infix'] }}'
        - require:
            - file: ensure_nexus_parent_deployment_dir

nexus_data_dir_exists:
    file.exists:
        - name: '/usr/local/sonatype-work'
        - user: {{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}
        - group: {{ pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}
        - require:
            - cmd: extract_nexus_archive

nexus_deployment_dir_exists:
    file.exists:
        - name: '/usr/local/nexus-{{ pillar['registered_content_items']['nexus_maven_repository_manager']['nexus_bundle_version_infix'] }}'
        - user: {{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}
        - group: {{ pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}
        - require:
            - cmd: extract_nexus_archive

set_nexus_deployment_dir_generic_symlink:
    file.symlink:
        - name: '/usr/local/nexus'
        - target: '/usr/local/nexus-{{ pillar['registered_content_items']['nexus_maven_repository_manager']['nexus_bundle_version_infix'] }}'
        - require:
            - file: nexus_deployment_dir_exists

# This may later be a template to deploy.
ensure_nexus_properties_file:
    file.exists:
        - name: '/usr/local/nexus/conf/nexus.properties'
        - require:
            - file: set_nexus_deployment_dir_generic_symlink

{% endif %}

{% if False %}
# The following state does not work at the moment due to a bug:
#   https://github.com/saltstack/salt/issues/11900

activate_nexus_service:
    service.running:
        - name: nexus
        - enable: True
        - require:
            - TODO

{% else %}
# This is a workaround described in the similar issue:
#   https://github.com/saltstack/salt/issues/8444

# At the moment, no service is configured.
# Instead, Nexus can be run manually:
#   cd /usr/local/nexus
#   ./bin/nexus console
#   firefox //http://localhost:8081/nexus
# Default admin username:password: admin:admin123
# Default deployment username:password: deployment123:deployment123
# In order to deploy releases to Nexus, deployment user should be configured
# in the ~/.m2/settings.xml file, for example:
#   <server>
#     <id>nexus-snapshots</id>
#     <username>deployment</username>
#     <password>the_pass_for_the_deployment_user</password>
#   </server>
# The `id` should probably match `id` in `pom.xml` file used for
# deploying a release:
#   <distributionManagement>
#     <repository>
#       <id>nexus-snapshots</id>
#       <name>whatever</name>
#       <url>URL_TO_NEXUS</url>
#     </repository>
#   </distributionManagement>

{% if False %}
nexus_service_enable:
    cmd.run:
        - name: "systemctl enable nexus"
        - require:
            - TODO

nexus_service_start:
    cmd.run:
        - name: "systemctl start nexus"
        - require:
            - TODO
{% endif %} # Disabled by False

{% endif %} # Disabled by False


{% endif %} # enable_installation
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

{% endif %}
# >>>
###############################################################################

{% endif %}

