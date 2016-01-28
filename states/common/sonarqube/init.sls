# Default SonarQube installation

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('fc') or grains['os_platform_type'].startswith('rhel7') %}

sonar_package:
    pkg.installed:
        - name: sonar
        - skip_verify: True
        - aggregate: True
        - version: 4.5.6

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
       
# Start sonarqube service.
sonar_service:
    service.running:
        - name: sonar
        - enable: True
        - require:
            - pkg: sonar_package
            - file: deploy_sonar_configuration_file
        
{% endif %}
# >>>
###############################################################################


