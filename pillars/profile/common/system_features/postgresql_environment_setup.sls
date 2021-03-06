
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set project_name = props['project_name'] %}

# TODO: Move PostgreSQL installation into `common`.

system_features:

    # Configuration for PostgreSQL database.
    postgresql_environment_setup:

        # Force re-initialization of PostgreSQL database:
        force_posgresql_database_reinitialization: True

        # PostgreSQL installation directory.
        postgresql_dir: '/usr/pgsql-9.3'

        # PostgreSQL original service name.
        postgresql_orig_service_name: 'postgresql-9.3'

        # PostgreSQL service name for project_name server.
        postgresql_service_name: 'postgresql-{{ project_name }}'

        # PostgreSQL database directory with data files.
        # Default is `/var/lib/pgsql/9.3/data`.
        # NOTE: Do not set it here.
        #       It is computed based on `project_name_version_*` and other
        #       parameters within state itself.
        postgresql_data_directory: ~

###############################################################################
# EOF
###############################################################################

