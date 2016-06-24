# Default SonarQube installation

include:
    - common.mariadb

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('fc') or grains['os_platform_type'].startswith('rhel7') %}

{% set config_temp_dir = pillar['posix_config_temp_dir'] %}

# NOTE: Due to issues with some other Sonarqube versions,
#       the decision is to use specific version and
#       pre-downloaded RPM file from resources.
{% if False %}

sonar_package:
    pkg.installed:
        - name: sonar
        # NOTE: This repo is supposed to be configured.
        #       See `pillar['system_features']['yum_repos_configuration']`.
        - fromrepo: sonar_qube
        # NOTE: The package from the official repo is not signed.
        #       This argument does not seem to work on
        #       Fedora 22 with Salt `2015.5.5` - see workaround below.
        - skip_verify: True
        # NOTE: Do not agregate this package as its state function has
        #       specific arguments which may not be used when aggregated
        #       with others (not sure if such behaviour is true but
        #       it is a suspected bug on Salt side when aggregate is used).
        - aggregate: False
        - require:
            - sls: common.mariadb

# NOTE: Apparently, there is a Salt bug to propagate `skip_verify`
#       as `--nogpgcheck` argument to `yum`.
#       This state is response in case of `sonar_package` failure above - see:
#           https://docs.saltstack.com/en/latest/ref/states/requisites.html#onfail
ensure_sonar_package:
    cmd.run:
        - name: 'yum -y --nogpgcheck --enablerepo=sonar_qube install sonar'
        - onfail:

            # NOTE: Use `cmd` instead of `pkg` - see reason above.
            {% if False %}
            - pkg: sonar_package
            {% else %}
            - cmd: sonar_package
            {% endif %}

{% else %}

{% set resources_macro_lib = 'common/resource_symlinks/resources_macro_lib.sls' %}
{% from resources_macro_lib import get_registered_content_item_URI with context %}
{% from resources_macro_lib import get_registered_content_item_hash with context %}

retrieve_sonar_rpm_package:
    file.managed:
        - name: '{{ config_temp_dir }}/sonar/sonar.rpm'
        - source: {{ get_registered_content_item_URI('sonar_pre_downloaded_rpm') }}
        - source_hash: {{ get_registered_content_item_hash('sonar_pre_downloaded_rpm') }}
        - makedirs: True

sonar_package:
    cmd.run:
        - name: 'yum install -y {{ config_temp_dir }}/sonar/sonar.rpm'
        # NOTE: Do not reinstall sonar (if exists).
        - unless: 'rpm -qi sonar'
        - require:
            - file: retrieve_sonar_rpm_package

{% endif %}

# Deploy SonarQube init script
deploy_sonarqube_database_init_script:
    file.managed:
        - name: '{{ config_temp_dir }}/sonar_init.sql'
        - source: 'salt://common/sonarqube/sonar_init.sql'
        - template: jinja
        - makedirs: True
        - dir_mode: 755
        - mode: 755
        - require:

            # NOTE: Use `cmd` instead of `pkg` - see reason above.
            {% if False %}
            - pkg: sonar_package
            {% else %}
            - cmd: sonar_package
            {% endif %}

# Sonarqube Database Creation
run_sonarqube_database_create:
    cmd.run:

        # WARNING: Database init should only be run when it does not exits
        #          (otherwise it will repeatedly overwrite existing history).
        # NOTE: This requires mariadb fresh installation
        #       (when passord is not yet set).
        - name: "mysql -u root < {{ config_temp_dir }}/sonar_init.sql"

        # NOTE: User should manually drop DB in order for this script to run.
        #       Unless to check for existing database.
        #       In order to drop the database, execute this commands:
        #           shell> mysql -u root
        #           mysql> drop database sonar;
        - unless: "mysqlshow 'sonar' 1> /dev/null 2>&1"

        - require:
            - file: deploy_sonarqube_database_init_script

            # NOTE: Use `cmd` instead of `pkg` - see reason above.
            {% if False %}
            - pkg: sonar_package
            {% else %}
            - cmd: sonar_package
            {% endif %}

            - sls: common.mariadb

deploy_sonar_configuration_file:
    file.managed:
        - name: '/opt/sonar/conf/sonar.properties'
        - source: 'salt://common/sonarqube/sonar.properties'
        - template: jinja
        - makedirs: True
        - dir_mode: 755
        - mode: 755
        - require:

            # NOTE: Use `cmd` instead of `pkg` - see reason above.
            {% if False %}
            - pkg: sonar_package
            {% else %}
            - cmd: sonar_package
            {% endif %}

# Deploy systemd service unit file.
deploy_sonar_service_script:
    file.managed:
        - name: '/usr/lib/systemd/system/sonar.service'
        - source: 'salt://common/sonarqube/sonar.service'
        - template: jinja
        - makedirs: True
        - dir_mode: 755
        - mode: 755
        - require:

            # NOTE: Use `cmd` instead of `pkg` - see reason above.
            {% if False %}
            - pkg: sonar_package
            {% else %}
            - cmd: sonar_package
            {% endif %}

# Import macros to query info based on resource id.
{% set resources_macro_lib = 'common/resource_symlinks/resources_macro_lib.sls' %}
{% from resources_macro_lib import get_registered_content_item_URI with context %}
{% from resources_macro_lib import get_registered_content_item_base_name with context %}
{% from resources_macro_lib import get_registered_content_item_hash with context %}

# List of resource ids for each plugin.
{% set required_sonar_plugin_ids = pillar['system_features']['configure_sonar_qube']['install_plugins'] %}

# Loop through each plugin and deploy it.
{% for resource_id in required_sonar_plugin_ids %}

deploy_sonar_plugin_{{ resource_id }}:
    file.managed:
        - source: '{{ get_registered_content_item_URI(resource_id) }}'
        - name: '/opt/sonar/extensions/plugins/{{ get_registered_content_item_base_name(resource_id) }}'
        - source_hash: '{{ get_registered_content_item_hash(resource_id) }}'
        - mode: 644
        - makedirs: True
        - require:

            # NOTE: Use `cmd` instead of `pkg` - see reason above.
            {% if False %}
            - pkg: sonar_package
            {% else %}
            - cmd: sonar_package
            {% endif %}


{% endfor %}

# Start sonarqube service.
sonar_service:
    service.running:
        - name: sonar
        - enable: True
        # NOTE: Restart the service if there are any changes.
        - watch:

            # NOTE: Use `cmd` instead of `pkg` - see reason above.
            {% if False %}
            - pkg: sonar_package
            {% else %}
            - cmd: sonar_package
            {% endif %}

            - cmd: run_sonarqube_database_create
            - file: deploy_sonar_service_script
            - file: deploy_sonar_configuration_file

{% for resource_id in required_sonar_plugin_ids %}
            - file: deploy_sonar_plugin_{{ resource_id }}
{% endfor %}

{% endif %}

# >>>
###############################################################################:

