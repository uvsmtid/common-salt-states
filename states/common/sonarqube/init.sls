# Default SonarQube installation

include:
    - common.mariadb

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('fc') or grains['os_platform_type'].startswith('rhel7') %}

sonar_package:
    pkg.installed:
        - name: sonar
        - skip_verify: True
        - aggregate: True
        - require:
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
        - require:
            - pkg: sonar_package

{% endfor %}

# Deploy systemd service script.
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
        - require:
            - pkg: sonar_package
            - file: deploy_sonar_service_script
            - file: deploy_sonar_configuration_file
            - file: deploy_sonar_init_file
{% for resource_id in required_sonar_plugins %}
            - file: deploy_sonar_plugin_{{ resource_id }}
{% endfor %}

{% endif %}
# >>>
###############################################################################:

