# Default PostgreSQL installation

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('fc') %}


postgresql_server_package:
    pkg.installed:
        - name: postgresql-server
        - aggregate: True

init_postgresql_data:
    cmd.run:
        - name: 'postgresql-setup --initdb'
        - require:
            - pkg: postgresql_server_package

# File:
# -rw-------. 1 postgres postgres 4224 Jul 28 00:03 /var/lib/pgsql/data/pg_hba.conf
'/var/lib/pgsql/data/pg_hba.conf':
    file.managed:
        - source: 'salt://common/postgresql/pg_hba.conf'
        - template: jinja
        - user: postgres
        - group: postgres
        - mode: 600
        - require:
            - cmd: init_postgresql_data

# File:
# -rw-------. 1 postgres postgres 21388 Jul 28 00:03 /var/lib/pgsql/data/postgresql.conf
'/var/lib/pgsql/data/postgresql.conf':
    file.managed:
        - source: 'salt://common/postgresql/postgresql.conf'
        - template: jinja
        - user: postgres
        - group: postgres
        - mode: 600
        - require:
            - cmd: init_postgresql_data

# Start database service.
postgresql_service:
    service.running:
        - name: postgresql
        - enable: True
        - require:
            - pkg: postgresql_server_package
            - cmd: init_postgresql_data
        - watch:
            - file: '/var/lib/pgsql/data/pg_hba.conf'
            - file: '/var/lib/pgsql/data/postgresql.conf'

{% endif %}
# >>>
###############################################################################


