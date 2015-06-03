
###############################################################################
#

system_features:

    maven_repository_manager_configuration:

        primary_maven_repository_manager: ~

        # If set to null `~`, this configures `settings.xml` to avoid using
        # proxy configuration and stick with default (publicly available
        # Internet Maven repos), otherwise use one of the roles configured
        # in `maven_repository_managers`.
        proxy_maven_repository_manager: ~

        maven_repository_managers:

            maven_repository_upstream_manager_role:
                # The following strings will be concatenated togheter with
                # `maven_repo_url_*_path_part` to form a complete URL.
                maven_repo_url_scheme_part: 'http://'
                maven_repo_url_port_part: ':8081/'

                maven_repo_url_releases_path_part: 'nexus/content/repositories/releases'
                maven_repo_url_snapshots_path_part: 'nexus/content/repositories/snapshots'
                maven_repo_url_public_path_part: 'nexus/content/groups/public'

            maven_repository_downstream_manager_role:
                # The following strings will be concatenated togheter with
                # `maven_repo_url_*_path_part` to form a complete URL.
                maven_repo_url_scheme_part: 'http://'
                maven_repo_url_port_part: ':8081/'

                maven_repo_url_releases_path_part: 'nexus/content/repositories/releases'
                maven_repo_url_snapshots_path_part: 'nexus/content/repositories/snapshots'
                maven_repo_url_public_path_part: 'nexus/content/groups/public'

###############################################################################
# EOF
###############################################################################

