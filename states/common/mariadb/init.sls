# Default MariaDB installation

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('fc') or grains['os_platform_type'].startswith('rhel7') %}

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

{% endif %}
# >>>
###############################################################################


