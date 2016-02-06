# Default SonarQube installation

include:
    - common.mariadb

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('fc') or grains['os_platform_type'].startswith('rhel7') %}

{% set config_temp_dir = pillar['posix_config_temp_dir'] %}

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

# NOTE: Apparently, there is a Salt bug to propaget `skip_verify`
#       as `--nogpgcheck` argument to `yum`.
#       This state is response in case of `sonar_package` failure above - see:
#           https://docs.saltstack.com/en/latest/ref/states/requisites.html#onfail
ensure_sonar_package:
    cmd.run:
        - name: 'yum -y --nogpgcheck --enablerepo=sonar_qube install sonar'
        - onfail:
            - pkg: sonar_package

# Deploy SonarQube init script
deploy_sonarqube_init_script:
    file.managed:
        - name: '{{ config_temp_dir }}/sonar_init.sql'
        - source: 'salt://common/sonarqube/sonar_init.sql'
        - template: jinja
        - makedirs: True
        - dir_mode: 755
        - mode: 755
        - require:
            - pkg: sonar_package

# Sonarqube Database Creation
run_sonarqube_database_create:
    cmd.run:
        # TODO: Database init should only be run when it does not exits.
        #       User should manually drop DB in order for this script to run.
        #       Add `unless` to check for existing database.
        - name: "mysql -u root < {{ config_temp_dir }}/sonar_init.sql"
        # NOTE: We do not run SQL every time (only when there are changes).
        - onchanges:
            - file: deploy_sonarqube_init_script
        - require:
            - pkg: sonar_package
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
            - pkg: sonar_package

{% if False %}
# DISABLED: Instead of init.d file, we use systemd unit file.
deploy_sonar_init_file:
    file.managed:
        - name: '/etc/init.d/sonar'
        - source: 'salt://common/sonarqube/sonar'
        - template: jinja
        - makedirs: True
        - dir_mode: 755
        - mode: 755
        - require:
            - pkg: sonar_package
{% endif %}

# OBS-975: This file is overriding extension deployed by default.
#          The new file exports the environment variable for Java 7.
remove_sonar_plugin_java_default:
    file.absent:
        - name: '/opt/sonar/extensions/plugins/sonar-java-plugin-3.7.1.jar'

# Import macros to query info based on resource id.
{% set resources_macro_lib = 'common/resource_symlinks/resources_macro_lib.sls' %}
{% from resources_macro_lib import get_registered_content_item_URI with context %}
{% from resources_macro_lib import get_registered_content_item_base_name with context %}
{% from resources_macro_lib import get_registered_content_item_hash with context %}

# List of resource ids for each plugin.
{% set required_sonar_plugins = [
        'sonar_plugin_java'
    ]
%}

# Loop through each plugin and deploy it.
{% for resource_id in required_sonar_plugins %}

deploy_sonar_plugin_{{ resource_id }}:
    file.managed:
        - source: '{{ get_registered_content_item_URI(resource_id) }}'
        - name: '/opt/sonar/extensions/plugins/{{ get_registered_content_item_base_name(resource_id) }}'
        - source_hash: '{{ get_registered_content_item_hash(resource_id) }}'
        - mode: 644
        - makedirs: True
        - require:
            - pkg: sonar_package

{% endfor %}

# Deploy systemd service unitfile.
deploy_sonar_service_script:
    file.managed:
        - name: '/usr/lib/systemd/system/sonar.service'
        - source: 'salt://common/sonarqube/sonar.service'
        - template: jinja
        - makedirs: True
        - dir_mode: 755
        - mode: 755
        - require:
            - pkg: sonar_package

# Start sonarqube service.
sonar_service:
    service.running:
        - name: sonar
        - enable: True
        # NOTE: Restart the service if there are any changes.
        - watch:
            - pkg: sonar_package
            - cmd: run_sonarqube_database_create
            - file: deploy_sonar_service_script
            - file: deploy_sonar_configuration_file
            - file: remove_sonar_plugin_java_default
{% for resource_id in required_sonar_plugins %}
            - file: deploy_sonar_plugin_{{ resource_id }}
{% endfor %}

{% endif %}
# >>>
###############################################################################:

