# Default MariaDB installation

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('fc') or grains['os_platform_type'].startswith('rhel7') %}

# NOTE: This is required to have uninitialized (blank) root password.
# TODO: Find more reliable solution - this has to be done properly
#       using stages (to allow automatic passwordless access and
#       disallow later).
# See:
#    http://stackoverflow.com/a/20270952/441652
{% if False %}
avoid_mariadb_residual_configuration_/etc/my.cnf:
    file.missing:
        - name: '/etc/my.cnf'
avoid_mariadb_residual_configuration_/var/lib/mysql:
    file.missing:
        - name: '/var/lib/mysql'
{% endif %}

mariadb_server_package:
    pkg.installed:
        - name: mariadb-server
        - aggregate: True
        - required:

# Start database service.
mariadb_service:
    service.running:
        - name: mariadb
        - enable: True
        - require:
            - pkg: mariadb_server_package

{% endif %}
# >>>
###############################################################################


