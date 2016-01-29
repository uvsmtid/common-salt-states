# Default MariaDB installation

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('fc') or grains['os_platform_type'].startswith('rhel7') %}

{% set config_temp_dir = pillar['posix_config_temp_dir'] %}

mariadb_package:
    pkg.installed:
        - name: mariadb
        - aggregate: True

mariadb_server_package:
    pkg.installed:
        - name: mariadb-server
        - aggregate: True



deploy_mariadb_configuration_file:
    file.managed:
        - name: '/etc/my.cnf'
        - source: 'salt://common/mariadb/my.cnf'
        - template: jinja
        - makedirs: True
        - dir_mode: 755
        - mode: 755
        - require:
            - pkg: mariadb_package
            - pkg: mariadb_server_package
       
# Start database service.
mariadb_service:
    service.running:
        - name: mariadb
        - enable: True
        - require:
            - pkg: mariadb_package
            - pkg: mariadb_server_package
            - file: deploy_mariadb_configuration_file

# Deploy SonarQube init script
deploy_sonarqube_init_script:
    file.managed:
        - name: '{{ config_temp_dir }}/sonar_init.sql'
        - source: 'salt://common/mariadb/sonar_init.sql'
        - template: jinja                                                       
        - makedirs: True                                                        
        - dir_mode: 755                                                         
        - mode: 755

# Sonarqube Database Creation
run_sonarqube_database_create:
    cmd.run:
        - name : "mysql -u root < {{ config_temp_dir }}/sonar_init.sql"
                
{% endif %}
# >>>
###############################################################################


